#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

echo -e "${RED}+-+-+-+-+-+-+-+-+-+-+${RESET}"
echo -e "${GREEN}|C|O|R|S|i|c|a|n|e|z|${RESET}"
echo -e "${RED}+-+-+-+-+-+-+-+-+-+-+${RESET}"

echo -e "${CYAN}%           %${RESET}"
echo -e "${CYAN}    %           %${RESET}"
echo -e "${CYAN}       %           %${RESET}"
echo -e "${CYAN}          %          %${RESET}"
echo -e "${CYAN}            %          %${RESET}"
echo -e "${CYAN}              %          %                   :::${RESET}"
echo -e "${CYAN}               %          %                ::::::${RESET}"
echo -e "${CYAN}            %%%%%%  %%%%%%%%%            ::::::::${RESET}"
echo -e "${CYAN}         %%%%%ZZZZ%%%%%%   %%%ZZZZ     ::::::::::         ::::::${RESET}"
echo -e "${CYAN}        %%%ZZZZZ%%%%%%%%%%%%%%ZZZZZZ  :::::::::::    :::::::::::::::::${RESET}"
echo -e "${CYAN}        ZZZ%ZZZ%%%%%%%%%%%%%%%ZZZZZZZ::::::::::***:::::::::::::::::::::${RESET}"
echo -e "${CYAN}     ZZZ%ZZZZZZ%%%%%%%%%%%%%%ZZZZZZZZZ::::::***:::::::::::::::::::::::${RESET}"
echo -e "${CYAN}   ZZZ%ZZZZZZZZZZ%%%%%%%%%%ZZZZZZ%ZZZZ:::***:::::::::::::::::::::::${RESET}"
echo -e "${CYAN}  ZZ%ZZZZZZZZZZZZZZZZZZZZZZZ%%%%% %ZZZ:**::::::::::::::::::::::${RESET}"
echo -e "${CYAN} ZZ%ZZZZZZZZZZZZZZZZZZZ%%%%% | | %ZZZ *:::::::::::::::::::${RESET}"
echo -e "${CYAN} Z%ZZZZZZZZZZZZZZZ%%%%%%%%%%%%%%%ZZZ::::::::::::::::::::::::::{RESET}"
echo -e "${CYAN}  ZZZZZZZZZZZ%%%%%ZZZZZZZZZZZZZZZZZ%%%%:::ZZZZ:::::::::::::::::${RESET}"
echo -e "${CYAN}    ZZZZ%%%%%ZZZZZZZZZZZZZZZZZZ%%%%%ZZZ%%ZZZ%ZZ%%*:::::::::::${RESET}"
echo -e "${CYAN}       ZZZZZZZZZZZZZZZZZZ%%%%%%%%%ZZZZZZZZZZ%ZZ%:::*::::::{RESET}"
echo -e "${CYAN}       *:::%%%%%%%%%%%%%%%%%%%%%%%ZZZZZZZZZZ%%%*::::*:::{RESET}"
echo -e "${CYAN}     *:::::::%%%%%%%%%%%%%%%%%%%%%%%ZZZZZ%%      *:::Z${RESET}"
echo -e "${CYAN}    **:ZZZZ:::%%%%%%%%%%%%%%%%%%%%%%%%%%%ZZ      ZZZZZ${RESET}"
echo -e "${CYAN}   *:ZZZZZZZ       %%%%%%%%%%%%%%%%%%%%%ZZZZ    ZZZZZZZ${RESET}"
echo -e "${CYAN}  *::::ZZZZZZ         %%%%%%%%%%%%%%%ZZZZZZZ      ZZZ${RESET}"
echo -e "${CYAN}   *::ZZZZZZ           Z%%%%%%%%%%%ZZZZZZZ%%${RESET}"
echo -e "${CYAN}     ZZZZ              ZZZZZZZZZZZZZZZZ%%%%%${RESET}"
echo -e "${CYAN}                      %%%ZZZZZZZZZZZ%%%%%%%%${RESET}"
echo -e "${CYAN}                     Z%%%%%%%%%%%%%%%%%%%%%${RESET}"
echo -e "${CYAN}                     ZZ%%%%%%%%%%%%%%%%%%%${RESET}"
echo -e "${CYAN}                     %ZZZZZZZZZZZZZZZZZZZ${RESET}"
echo -e "${CYAN}                     %%ZZZZZZZZZZZZZZZZZ${RESET}"
echo -e "${CYAN}                      %%%%%%%%%%%%%%%%${RESET}"
echo -e "${CYAN}                       %%%%%%%%%%%%%${RESET}"
echo -e "${CYAN}                        %%%%%%%%%${RESET}"
echo -e "${CYAN}                         ZZZZ${RESET}"
echo -e "${CYAN}                         ZZZ${RESET}"
echo -e "${CYAN}                        ZZ${RESET}"
echo -e "${CYAN}                       Z${RESET}"

echo -e "${RED}by KL3FT3Z${RESET}"
echo -e "${RED}Bash script detecting CORS Misconfiguration${RESET}"

run_gau() {
    local site="$1"
    if ! command -v gau &> /dev/null; then
        echo "GAU is not installed locally. Use Docker to run it."
        docker run --rm -i corbinlc/gau "$site"
    else
        gau "$site"
    fi
}

save_results() {
    local results="$1"
    echo -n "Do you want to save the results to a file? (y/n): "
    read -r answer
    if [[ "$answer" == "y" ]]; then
        echo -n "Enter the file name: "
        read -r filename
        echo -e "$results" > "$filename"
        echo "The results are saved in $filename"
    fi
}

# 1. Basic Origin Reflection
test_basic_origin_reflection() {
    local site="$1"
    local results=""
    echo "Testing Basic Origin Reflection..."

    run_gau "$site" | while read -r url; do
        response=$(curl -s -I -H "Origin: https://google.com" -X GET "$url")
        if echo "$response" | grep -q 'Access-Control-Allow-Origin: https://google.com'; then
            results+="[Potentional CORS Found] $url\n"
            echo "[Potentional CORS Found] $url"
        elif echo "$response" | grep -q 'HTTP/1.1 403\|HTTP/1.1 503'; then
            echo "Error on the $url: check availability. Code 403 or 503"
        else
            echo "Nothing on $url"
        fi
    done

    save_results "$results"
}

# 2. Trusted null Origin payload
test_trusted_null_origin() {
    local site="$1"
    local results=""
    echo "Testing Trusted Null Origin..."

    run_gau "$site" | while read -r url; do
        response=$(curl -s -I -H "Origin: null" -X GET "$url")
        if echo "$response" | grep -q 'Access-Control-Allow-Origin: null'; then
            results+="[Potentional CORS Found] $url\n"
            echo "[Potentional CORS Found] $url"
        elif echo "$response" | grep -q 'HTTP/1.1 403\|HTTP/1.1 503'; then
            echo "Error on the $url: check availability. Code 403 or 503"
        else
            echo "Nothing on $url"
        fi
    done

    save_results "$results"
}

# 3. Whitelisted null origin value payload
test_whitelisted_null_origin() {
    local site="$1"
    local results=""
    echo "Testing Whitelisted Null Origin..."

    run_gau "$site" | while read -r url; do
        response=$(curl -s -I -X GET "$url")
        if echo "$response" | grep -q 'Access-Control-Allow-Origin: null'; then
            results+="[Potentional CORS Found] $url\n"
            echo "[Potentional CORS Found] $url"
        elif echo "$response" | grep -q 'HTTP/1.1 403\|HTTP/1.1 503'; then
            echo "Error on the $url: check availability. Code 403 or 503"
        else
            echo "Nothing on $url"
        fi
    done

    save_results "$results"
}

# 4. Trusted subdomain in Origin payload
test_trusted_subdomain_origin() {
    local site="$1"
    local results=""
    echo "Testing Trusted Subdomain in Origin..."

    run_gau "$site" | while read -r url; do
        response=$(curl -s -I -H "Origin: evil.$site" -X GET "$url")
        if echo "$response" | grep -q "Access-Control-Allow-Origin: evil.$site"; then
            results+="[Potentional CORS Found] $url\n"
            echo "[Potentional CORS Found] $url"
        elif echo "$response" | grep -q 'HTTP/1.1 403\|HTTP/1.1 503'; then
            echo "Error on the $url: check availability. Code 403 or 503"
        else
            echo "Nothing on $url"
        fi
    done

    save_results "$results"
}

# 5. Abuse on not properly Domain validation
test_abuse_domain_validation() {
    local site="$1"
    local results=""
    local domain=$(echo "$site" | sed 's|https://||g; s|http://||g')
    echo "Testing Abuse on Domain Validation..."

    run_gau "$site" | while read -r url; do
        response=$(curl -s -I -H "Origin: https://not$domain" -X GET "$url")
        if echo "$response" | grep -q "Access-Control-Allow-Origin: https://not$domain"; then
            results+="[Potentional CORS Found] $url\n"
            echo "[Potentional CORS Found] $url"
        elif echo "$response" | grep -q 'HTTP/1.1 403\|HTTP/1.1 503'; then
            echo "Error on the $url: check availability. Code 403 or 503"
        else
            echo "Nothing on $url"
        fi
    done

    save_results "$results"
}

# 6. Origin domain extension not validated vulnerability
test_origin_domain_extension() {
    local site="$1"
    local results=""
    echo "Testing Origin Domain Extension Vulnerability..."

    run_gau "$site" | while read -r url; do
        response=$(curl -s -I -H "Origin: $site.evil.com" -X GET "$url")
        if echo "$response" | grep -q "Access-Control-Allow-Origin: $site.evil.com"; then
            results+="[Potentional CORS Found] $url\n"
            echo "[Potentional CORS Found] $url"
        elif echo "$response" | grep -q 'HTTP/1.1 403\|HTTP/1.1 503'; then
            echo "Error on the $url: check availability. Code 403 or 503"
        else
            echo "Nothing on $url"
        fi
    done

    save_results "$results"
}

# 7. Advanced Bypassing using special characters + encoded
test_advanced_bypassing() {
    local site="$1"
    local payloads=("!" "(" ")" "'" ";" "=" "^" "{" "}" "|" "~" '"' '`' "," "%60" "%0b")
    local results=""
    echo "Testing Advanced Bypassing..."

    for payload in "${payloads[@]}"; do
        response=$(curl -s -I -H "Origin: $site$payload.evil.com" -X GET "$site")
        if echo "$response" | grep -q "$site$payload.evil.com"; then
            results+="[+] Payload Reflected: $site$payload.evil.com\n"
            echo "[+] Payload Reflected: $site$payload.evil.com"
        elif echo "$response" | grep -q 'HTTP/1.1 403\|HTTP/1.1 503'; then
            echo "Error on $site$payload.evil.com : check availability. Code 403 or 503"
        else
            echo "Nothing found with: $site$payload.evil.com"
        fi
    done

    save_results "$results"
}

main() {
    echo -n "Enter the URL of the website for testing (for example, https://example.com ): "
    read -r site

    if [[ -z "$site" ]]; then
        echo "Error: The site URL cannot be empty."
        exit 1
    fi

    test_basic_origin_reflection "$site"
    test_trusted_null_origin "$site"
    test_whitelisted_null_origin "$site"
    test_trusted_subdomain_origin "$site"
    test_abuse_domain_validation "$site"
    test_origin_domain_extension "$site"
    test_advanced_bypassing "$site"
}

main
