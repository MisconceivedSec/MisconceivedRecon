#!/bin/bash

## Colours + Formatting

blue=$'\e[34m'
orange=$'\e[33m'
yellow=$'\e[93m'
red=$'\e[31m'
green=$'\e[32m'
cyan=$'\e[36m'
magenta=$'\e[35m'
bold=$'\e[1m'
italic=$'\e[3m'
underline=$'\e[4m'
reset=$'\e[0m'

default_tasks=("subdomain" "screenshot" "fingerprint" "deep_domains" "leaks")
version="2.3"

## Functions

my_date() {
    date +%a\ %e\ %b\ %H:%M:%S\ %Y
}

print_banner() {
    if [[ $(tput cols) -ge 90 ]]; then
        echo '   __  ___ _                                _                __ ___                      '
        echo '  /  |/  /(_)___ ____ ___   ___  ____ ___  (_)_  __ ___  ___/ // _ \ ___  ____ ___   ___ '
        echo ' / /|_/ // /(_-</ __// _ \ / _ \/ __// -_)/ /| |/ // -_)/ _  // , _// -_)/ __// _ \ / _ \'
        echo '/_/  /_//_//___/\__/ \___//_//_/\__/ \__//_/ |___/ \__/ \_,_//_/|_| \__/ \__/ \___//_//_/'
        echo "                                                                       ${red}Mr. Misconception${reset}"
    else
        echo "   __  ___ ___"
        echo "  /  |/  // _ \\  MisconceivedRecon"
        echo " / /|_/ // , _/  ${red}Mr. Misconception${reset}"
        echo "/_/  /_//_/|_|"
    fi
}

print_info() {    
    [[ $mode ]] && print_sub "Mode: ${yellow}$mode${reset}"
    [[ $target ]] && print_sub "Target:" "${yellow}$target${reset}"
    [[ $config_file ]] && print_sub "Config File:" "${yellow}${underline}$config_file${reset}"
    echo ""
}

print_error() {
    echo -e "${bold}${red}Error:${reset} $1"
    [[ "$2" = "no_exit" ]] || exit 1
}

print_message() {                   
    echo -e "${blue}=>>${reset}${bold} $1${reset} $2"
}

print_minor() {
    echo -e "  ${red}-->${reset} $1"
}

print_task() {                   
    echo ""
    echo -e "${red}=>>${reset}${bold} $1${reset} $2"
    wait_for_internet
    [[ $logs_webhook ]] && send_to_discord "- *${1}*" $logs_webhook
}

print_sub() {                   
    echo -e "${orange}=>>${reset}${bold} $1${reset} $2"
}

print_green() {
    echo ""
    echo -e "${bold}${green}=>>${reset}${bold} ${underline}$1${reset} $2"
    echo ""
}

print_warning() {
    echo -e "${magenta}=>>${reset}${bold} $1${reset} $2"
}

print_announce() {
    start_date="$(my_date)"

    print_green "$1" "${italic}${yellow}($start_date)${reset}"
    wait_for_internet    
    send_to_discord "__**$1** ($start_date)__" $logs_webhook
}

prompt() {
    read -p "   ${red}->${reset} $1 " userinput
    echo ""
}

send_to_discord() {
    message="$1"
    webhook="$2"
    upload_file="$3"

    if [[ $webhook ]]; then
        if [[ $upload_file ]]; then
            discord.sh --webhook-url="$webhook" --username 'MisconceivedRecon' --avatar 'https://i.imgur.com/eFlbVl2.jpg' --text "$message" --file "$upload_file"
        else
            discord.sh --webhook-url="$webhook" --username 'MisconceivedRecon' --avatar 'https://i.imgur.com/eFlbVl2.jpg' --text "$message"
        fi
    fi
}

my_diff() {
    old=$1
    new=$2
    report=$3
    webhook=$4

    difference="$([[ -r $old ]] && colordiff $old $new | sed -e "s/</-/g" -e "s/>/+/g" | grep -Ev '\---')"

    if [[ $difference ]]; then
        print_warning "Found changes in report: ${report}"
        echo -e "$difference"

        if [[ $webhook ]]; then
            print_message "Uploading difference in:" "${report} report"
            send_to_discord "Changes in **\`${report}\`**:\n\`\`\`diff\n${difference}\n\`\`\`" $webhook
        fi
    fi
}

wait_for_internet() {
    server='1.1.1.1'
    _ping=$(ping $server -c 1 2> /dev/null)

    if [[ "$_ping" = *"100% packet loss"* || ! "$_ping" ]]; then
        print_warning "Can't connect to the internet - Waiting..."

        while true; do
            _ping=$(ping $server -c 1 2> /dev/null)
            
            if ! [[ "$_ping" = *"100% packet loss"* || ! "$_ping" ]]; then
                break
            fi

            sleep 10
        done

        print_message "Connected!"
    fi
}

help() {
    print_banner
    print_info

    if [[ "$1" = "init" ]]; then
        echo "${green}${bold}Usage:${reset} $0 ${cyan}init${reset} [OPTIONS]"
        echo ""
        echo "${green}${bold}Flags:${reset}"
        echo "  ${magenta}${bold}-t -target${reset} <domain>"
        echo "         ${bold}Mandatory:${reset} Target domain"
        echo "  ${magenta}${bold}-ght -github-token${reset} <token>"
        echo "         ${bold}Mandatory:${reset} GitHub Access Token"
        echo "  ${magenta}${bold}-sr -scope-regex${reset} <regex>"
        echo "         Regex to filter for in-scope domains"
        echo "  ${magenta}${bold}-b -brute-wordlists${reset} <file[,file,...]>"
        echo "         Wordlist(s) for subdomain brute-forcing"
        echo "  ${magenta}${bold}-ghr -github-recon${reset} <url[,url,...]>"
        echo "         GitHub Repos to enumerate"
        echo "  ${magenta}${bold}-glt -gitlab-token${reset} <token>"
        echo "         GitLab Token"
        echo "  ${magenta}${bold}-glr -gitlab-recon${reset} <url[,url,...]>"
        echo "         GitLab Repos to enumerate"
        echo "  ${magenta}${bold}-p -path${reset} <path>"
        echo "         Path to recon report directory"
        echo "  ${magenta}${bold}-ct -custom-tasks${reset} <task[,task,...]>"
        echo "         Custom task sequence"
        echo "  ${magenta}${bold}-d -deep-domains${reset} <domain> <wordlist>"
        echo "         Domains preform to deep recon on"        
        echo "  ${magenta}${bold}-ws -subdomain-webhook${reset} <url>"
        echo "         Subdomain Webhook" 
        echo "  ${magenta}${bold}-wc -screenshots-webhook${reset} <url>"
        echo "         Screenshots Webhook"        
        echo "  ${magenta}${bold}-wf -fingerprint-webhook${reset} <url>"
        echo "         Fingerprint/Services Webhook"        
        echo "  ${magenta}${bold}-wd -deep-domain-webhook${reset} <url>"
        echo "         Deep Domain Webhook"        
        echo "  ${magenta}${bold}-wl -leaks-webhook${reset} <url>"
        echo "         Leaks Webhook"        
        echo "  ${magenta}${bold}-wg -logs-webhook${reset} <url>"
        echo "         Logs Webhook"            
        echo "  ${magenta}${bold}-h -help${reset}"
        echo "         ${bold}Standalone:${reset} Print this help message"
        echo ""
        echo "(Must provide ${bold}all${reset} webhooks together, or ${bold}none${reset} at all)"
        echo ""
        echo "${green}${bold}Available Recon Tasks:${reset}"
        for attack in ${default_tasks[*]}; do
            echo "  ${bold}${attack}${reset}"
        done
    elif [[ "$1" = "config" ]]; then
        echo "${green}${bold}Usage:${reset} $0 ${cyan}config${reset} [OPTIONS]"
        echo ""
        echo "${green}${bold}Flags:${reset}"
        echo "  ${magenta}${bold}-c -config-file${reset} <file>"
        echo "         ${bold}Mandatory:${reset} <Configuration file for target>"
        echo "  ${magenta}${bold}-t -target${reset} <domain>"
        echo "         Change target domain"
        echo "  ${magenta}${bold}-sr -scope-regex${reset} <regex>"
        echo "         Regex to filter for in-scope domains"
        echo "  ${magenta}${bold}-b -brute-wordlists${reset} <file[,file,...]>"
        echo "         Add wordlist(s) for subdomain brute-forcing"
        echo "  ${magenta}${bold}-ght -github-token${reset} <token>"
        echo "         Change GitHub Token"
        echo "  ${magenta}${bold}-ghr -github-recon${reset} <url[,url,...]>"
        echo "         Add GitHub Repos to enumerate"
        echo "  ${magenta}${bold}-glt -gitlab-token${reset} <token>"
        echo "         Change GitLab Token"
        echo "  ${magenta}${bold}-glr -gitlab-recon${reset} <url[,url,...]>"
        echo "         Add GitLab Repos to enumerate"
        echo "  ${magenta}${bold}-a -attack-method${reset} <task[,task,...]>"
        echo "         Change task sequence"
        echo "  ${magenta}${bold}-d -deep-domains${reset} <domain> <wordlist>"
        echo "         Add domains for deep recon"        
        echo "  ${magenta}${bold}-ws -subdomain-webhook${reset} <url>"
        echo "         Change Subdomain Webhook"      
        echo "  ${magenta}${bold}-wc -screenshots-webhook${reset} <url>"
        echo "         Change Screenshots Webhook"  
        echo "  ${magenta}${bold}-wf -fingerprint-webhook${reset} <url>"
        echo "         Change Fingerprint/Service Webhook"     
        echo "  ${magenta}${bold}-wd -deep-domain-webhook${reset} <url>"
        echo "         Change Deep Domain Webhook"
        echo "  ${magenta}${bold}-wl -leaks-webhook${reset} <url>"
        echo "         Change Leaks Webhook"        
        echo "  ${magenta}${bold}-wg -logs-webhook${reset} <url>"
        echo "         Change Logs Webhook"
        echo "  ${magenta}${bold}-m -manual [editor]${reset}"
        echo "         ${bold}Standalone:${reset} Edit the config file manually (default editor 'nano')"
        echo "  ${magenta}${bold}-h -help${reset}"
        echo "         ${bold}Standalone:${reset} Print this help message"
        echo ""
        echo "${green}${bold}Available Recon Tasks:${reset}"
        for attack in ${default_tasks[*]}; do
            echo "  ${bold}${attack}${reset}"
        done
    elif [[ $1 =~ subdomain|screenshot|fingerprint|deep|leaks|gdork|recon ]]; then
        echo "${green}${bold}Usage:${reset} $0 ${cyan}recon${reset}|${cyan}subdomain${reset}|${cyan}screenshot${reset}|${cyan}fingerprint${reset}|${cyan}deep${reset}|${cyan}leaks${reset}|${cyan}gdork${reset} [OPTIONS]"
        echo ""
        echo "${green}${bold}Flags:${reset}"
        echo "  ${magenta}${bold}-c -config-file${reset} file"
        echo "         ${bold}Mandatory:${reset} Configuration file for target"
        echo ""
    elif [[ $1 = "report" ]]; then
        echo "${green}${bold}Usage:${reset} $0 report [OPTIONS]"
        echo ""
        echo "${green}${bold}Flags:${reset}"
        echo "  ${magenta}${bold}-c -config-file${reset} <file>"
        echo "         ${bold}Mandatory:${reset} Configuration file for target"
        echo "  ${magenta}${bold}-r -report${reset} <report>"
        echo "         Specify report"
        echo "  ${magenta}${bold}-s -sub-report${reset} <sub-report>"
        echo "         Specify sub-report"
        echo ""
    else
        echo "${green}${bold}Usage:${reset} $0 MODE [OPTIONS]"
        echo "${green}${bold}Version:${reset} $version"
        echo ""
        echo "${green}${bold}Modes:${reset}"
        echo "    ${cyan}help   ${yellow}=>${reset} Print this help message"
        echo "    ${cyan}init   ${yellow}=>${reset} Initiate configuration for recon on target"
        echo "    ${cyan}config ${yellow}=>${reset} Modify configuration of specific target"        
        echo "    ${cyan}recon  ${yellow}=>${reset} Run recon based on configuration file"
        echo "    ${cyan}report ${yellow}=>${reset} Show reports and subreports of enumeration tasks"
        echo ""
        echo "${green}${bold}Functions:${reset}"    
        echo "    ${cyan}subdomain   ${yellow}=>${reset} Subdomain Recon"
        echo "    ${cyan}screenshot  ${yellow}=>${reset} Screenshots of Subdomains"
        echo "    ${cyan}fingerprint ${yellow}=>${reset} Fingerprint/Service Scan"
        echo "    ${cyan}deep        ${yellow}=>${reset} Deep Domain Recon"
        echo "    ${cyan}leaks       ${yellow}=>${reset} Scan GiHub/GitLab repos for leaks"
        echo "    ${cyan}gdork       ${yellow}=>${reset} Generate GitHub Dorking Links"
        echo ""
        echo "Parse ${magenta}${bold}-h${reset} or ${magenta}${bold}-help${reset} with each mode/function for more information"
    fi
    exit
}

probe() {
    httprobe -p http:8080 -p http:8000 -p http:8008 -p http:8081 -p http:8888 -p http:8088 -p http:8880 -p http:8001 -p http:8082 -p http:8787 -p https:8443 -p https:8444 -p https:9443 -p https:4433 -p https:4343
}

extract_url() {
    cut -d ':' -f 1-2 | sed -e "s/http:\/\///" -e "s/https:\/\///" | sort -u
}

github_dorking_links() {

    init_vars
    print_banner
    print_info

    {
        echo "https://github.com/search?q=\"${target}\"+password&type=Code"
        echo "https://github.com/search?q=\"${org}\"+password&type=Code"
        echo "https://github.com/search?q=\"${target}\"+npmrc%20_auth&type=Code"
        echo "https://github.com/search?q=\"${org}\"+npmrc%20_auth&type=Code"
        echo "https://github.com/search?q=\"${target}\"+dockercfg&type=Code"
        echo "https://github.com/search?q=\"${org}\"+dockercfg&type=Code"
        echo "https://github.com/search?q=\"${target}\"+pem%20private&type=Code"
        echo "https://github.com/search?q=\"${org}\"+extension:pem%20private&type=Code"
        echo "https://github.com/search?q=\"${target}\"+id_rsa&type=Code"
        echo "https://github.com/search?q=\"${org}\"+id_rsa&type=Code"
        echo "https://github.com/search?q=\"${target}\"+aws_access_key_id&type=Code"
        echo "https://github.com/search?q=\"${org}\"+aws_access_key_id&type=Code"
        echo "https://github.com/search?q=\"${target}\"+s3cfg&type=Code"
        echo "https://github.com/search?q=\"${org}\"+s3cfg&type=Code"
        echo "https://github.com/search?q=\"${target}\"+htpasswd&type=Code"
        echo "https://github.com/search?q=\"${org}\"+htpasswd&type=Code"
        echo "https://github.com/search?q=\"${target}\"+git-credentials&type=Code"
        echo "https://github.com/search?q=\"${org}\"+git-credentials&type=Code"
        echo "https://github.com/search?q=\"${target}\"+bashrc%20password&type=Code"
        echo "https://github.com/search?q=\"${org}\"+bashrc%20password&type=Code"
        echo "https://github.com/search?q=\"${target}\"+sshd_config&type=Code"
        echo "https://github.com/search?q=\"${org}\"+sshd_config&type=Code"
        echo "https://github.com/search?q=\"${target}\"+xoxp%20OR%20xoxb%20OR%20xoxa&type=Code"
        echo "https://github.com/search?q=\"${org}\"+xoxp%20OR%20xoxb&type=Code"
        echo "https://github.com/search?q=\"${target}\"+SECRET_KEY&type=Code"
        echo "https://github.com/search?q=\"${org}\"+SECRET_KEY&type=Code"
        echo "https://github.com/search?q=\"${target}\"+client_secret&type=Code"
        echo "https://github.com/search?q=\"${org}\"+client_secret&type=Code"
        echo "https://github.com/search?q=\"${target}\"+sshd_config&type=Code"
        echo "https://github.com/search?q=\"${org}\"+sshd_config&type=Code"
        echo "https://github.com/search?q=\"${target}\"+github_token&type=Code"
        echo "https://github.com/search?q=\"${org}\"+github_token&type=Code"
        echo "https://github.com/search?q=\"${target}\"+api_key&type=Code"
        echo "https://github.com/search?q=\"${org}\"+api_key&type=Code"
        echo "https://github.com/search?q=\"${target}\"+FTP&type=Code"
        echo "https://github.com/search?q=\"${org}\"+FTP&type=Code"
        echo "https://github.com/search?q=\"${target}\"+app_secret&type=Code"
        echo "https://github.com/search?q=\"${org}\"+app_secret&type=Code"
        echo "https://github.com/search?q=\"${target}\"+passwd&type=Code"
        echo "https://github.com/search?q=\"${org}\"+passwd&type=Code"
        echo "https://github.com/search?q=\"${target}\"+.env&type=Code"
        echo "https://github.com/search?q=\"${org}\"+.env&type=Code"
        echo "https://github.com/search?q=\"${target}\"+.exs&type=Code"
        echo "https://github.com/search?q=\"${org}\"+.exs&type=Code"
        echo "https://github.com/search?q=\"${target}\"+beanstalkd.yml&type=Code"
        echo "https://github.com/search?q=\"${org}\"+beanstalkd.yml&type=Code"
        echo "https://github.com/search?q=\"${target}\"+deploy.rake&type=Code"
        echo "https://github.com/search?q=\"${org}\"+deploy.rake&type=Code"
        echo "https://github.com/search?q=\"${target}\"+mysql&type=Code"
        echo "https://github.com/search?q=\"${org}\"+mysql&type=Code"
        echo "https://github.com/search?q=\"${target}\"+credentials&type=Code"
        echo "https://github.com/search?q=\"${org}\"+credentials&type=Code"
        echo "https://github.com/search?q=\"${target}\"+PWD&type=Code"
        echo "https://github.com/search?q=\"${org}\"+PWD&type=Code"
        echo "https://github.com/search?q=\"${target}\"+deploy.rake&type=Code"
        echo "https://github.com/search?q=\"${org}\"+deploy.rake&type=Code"
        echo "https://github.com/search?q=\"${target}\"+.bash_history&type=Code"
        echo "https://github.com/search?q=\"${org}\"+.bash_history&type=Code"
        echo "https://github.com/search?q=\"${target}\"+.sls&type=Code"
        echo "https://github.com/search?q=\"${org}\"+PWD&type=Code"
        echo "https://github.com/search?q=\"${target}\"+secrets&type=Code"
        echo "https://github.com/search?q=\"${org}\"+secrets&type=Code"
        echo "https://github.com/search?q=\"${target}\"+composer.json&type=Code"
        echo "https://github.com/search?q=\"${org}\"+composer.json&type=Code"
        echo "https://github.com/search?q=\"${target}\"+snyk&type=Code"
        echo "https://github.com/search?q=\"${org}\"+snyk&type=Code"
    } > ${recon_dir}/github_dorking_links.txt

    cat ${recon_dir}/github_dorking_links.txt | xclip -selection clipboard
    print_task "GitHub Dorking Links Copied" "${red}-->${reset} ./$(realpath --relative-to="." "${recon_dir}/github_dorking.txt")"
}

subdomain_recon() {

    print_announce "Subdomain Enumeration"
    start_seconds=$SECONDS

    ## crt.sh
 
    print_task "Pulling down 'crt.sh' domains" "${red}-->${reset} ./$(realpath --relative-to="." "$subdomain_dir/crt_sh.txt")"
    [[ -f $subdomain_dir/crt_sh.txt ]] && mv $subdomain_dir/crt_sh.txt $subdomain_dir/crt_sh.old
    [[ -f $subdomain_dir/crt_sh_wildcard.txt ]] && mv $subdomain_dir/crt_sh_wildcard.txt $subdomain_dir/crt_sh_wildcard.old

    crt.sh -t "$target" > $subdomain_dir/crt_temp.txt
    cat $subdomain_dir/crt_temp.txt | grep -v '*' | tee $subdomain_dir/crt_sh.txt

    print_message "crt.sh wildcard domains"
    grep '*' $subdomain_dir/crt_temp.txt | tee $subdomain_dir/crt_sh_wildcard.txt

    rm $subdomain_dir/crt_temp.txt

    my_diff $subdomain_dir/crt_sh.old $subdomain_dir/crt_sh.txt "crt.sh"
    my_diff $subdomain_dir/crt_sh_wildcard.old $subdomain_dir/crt_sh_wildcard.txt "crt.sh wildcard domains"

    ## Subfinder

    print_task "Running 'subfinder'" "${red}-->${reset} ./$(realpath --relative-to="." "$subdomain_dir/subfinder.txt")"
    [[ -f $subdomain_dir/subfinder.old ]] && mv $subdomain_dir/subfinder.old $subdomain_dir/subfinder.txt

    subfinder -d "$target" -o $subdomain_dir/subfinder.txt

    my_diff $subdomain_dir/subfinder.old $subdomain_dir/subfinder.txt "subfinder"

    ## GitHub Subdomains

    print_task "Running 'github-subdomains.py'" "${red}-->${reset} ./$(realpath --relative-to="." "$subdomain_dir/github_subdomains.txt")"
    [[ -f $subdomain_dir/github_subdomains.txt ]] && mv $subdomain_dir/github_subdomains.txt $subdomain_dir/github_subdomains.old

    github-subdomains -t $ghtoken -d $target | tee $subdomain_dir/github_subdomain_unsorted.txt
    sleep 6
    github-subdomains -t $ghtoken -d $target | tee -a $subdomain_dir/github_subdomain_unsorted.txt
    sleep 6
    github-subdomains -t $ghtoken -d $target | tee -a $subdomain_dir/github_subdomain_unsorted.txt
    sleep 10
    github-subdomains -t $ghtoken -d $target | tee -a $subdomain_dir/github_subdomain_unsorted.txt

    sort -u $subdomain_dir/github_subdomain_unsorted.txt | grep -v "error occurred:" > $subdomain_dir/github_subdomains.txt
    rm $subdomain_dir/github_subdomain_unsorted.txt

    my_diff $subdomain_dir/github-subdomains.old $subdomain_dir/github-subdomains.txt "github-subdomains"

    ## Amass (doesn't work with my internet :/)

    # print_message "Running 'amass passive'"
    # [[ -f $subdomain_dir/amass_passive.txt ]] && mv $subdomain_dir/crt_sh.txt $subdomain_dir/amass_passive.old
    # amass enum --passive -d $target | sort -u | probe | tee -a $subdomain_dir/amass_passive.txt
    # my_diff $subdomain_dir/amass_passive.old $subdomain_dir/amass_passive.txt "amass passive"
    
    ## Combine & Sort Brute Lists

    print_message "Sorting & Combining Subdomain Brute-Force Wordlists"

    sort -u ${brute_wordlists[*]} > /tmp/${org}_subdomain_brute_wordlist.txt
    brute_wordlist=/tmp/${org}_subdomain_brute_wordlist.txt

    ## Gobuster

    print_task "Running 'gobuster' (brute-force)" "${red}-->${reset} ./$(realpath --relative-to="." "$subdomain_dir/gobuster.txt")"
    [[ -f $subdomain_dir/gobuster.txt ]] && mv $subdomain_dir/gobuster.txt $subdomain_dir/gobuster.old

    gobuster dns -d $target -w $brute_wordlist --no-color -o $subdomain_dir/temp_gobuster.txt 

    cut -d ' ' -f 2 $subdomain_dir/temp_gobuster.txt | grep -v '^[[:space:]]*$' > $subdomain_dir/gobuster.txt
    rm $subdomain_dir/temp_gobuster.txt
    
    my_diff $subdomain_dir/gobuster.old $subdomain_dir/gobuster.txt "gobuster"

    ## Combining Files

    print_message "Temporary Combination"
    cat $subdomain_dir/crt_sh.txt $subdomain_dir/subfinder.txt $subdomain_dir/github_subdomains.txt $subdomain_dir/gobuster.txt | sort -u > $subdomain_dir/combined_temp.txt

    ## Subdomainizer

    print_task "Running 'subdomainizer'" "${red}-->${reset} ./$(realpath --relative-to="." "$subdomain_dir/subdomainizer.txt")"
    [[ -f $subdomain_dir/subdomainizer.txt ]] && mv $subdomain_dir/subdomainizer.txt $subdomain_dir/subdomainizer.old
    [[ -f $subdomain_dir/subdomainizer_info.txt ]] && mv $subdomain_dir/subdomainizer_info.txt $subdomain_dir/subdomainizer_info.old

    subdomainizer -l combined_temp.txt -gt $ghtoken -g -o subdomainizer.txt
    grep "Found some secrets(might be false positive)..." -A 1000 subdomainizer.txt | sed '/___End\ of\ Results__/d' > $leaks_dir/subdomainizer_info.txt

    my_diff $subdomain_dir/subdomainizer.old $subdomain_dir/subdomainizer.txt "subdomainizer"
    my_diff $subdomain_dir/subdomainizer_info.old $subdomain_dir/subdomainizer_info.txt "subdomainizer leaks"
    
    ## Combining Files

    print_message "Combining Temp Combination with Subdomainizer Report"
    cat $subdomain_dir/combined_temp.txt $subdomain_dir/subdomainizer.txt | sort -u > $subdomain_dir/combined_subdomains.txt
    rm $subdomain_dir/combined_temp.txt

    ## Subfinder recursive

    print_task "Running 'subfinder recursive'" "${red}-->${reset} ./$(realpath --relative-to="." "$subdomain_dir/subfinder_recursive.txt")"
    [[ -f $subdomain_dir/subfinder_recursive.txt ]] && mv $subdomain_dir/subfinder_recursive.txt $subdomain_dir/subfinder_recursive.old

    subfinder -recursive -list $subdomain_dir/combined_subdomains.txt -o $subdomain_dir/subfinder_recursive.txt

    my_diff $subdomain_dir/subfinder_recursive.old $subdomain_dir/subfinder_recursive.txt "subfinder recursive"

    ## Combining Files

    print_message "Recursive Combination"
    cat $subdomain_dir/combined_subdomains.txt $subdomain_dir/subfinder_recursive.txt | sort -u > $subdomain_dir/combined_recursive.txt

    ## GoAltDNS

    print_task "Running 'goaltdns'" "${red}-->${reset} ./$(realpath --relative-to="." "$subdomain_dir/goaltdns.txt")"
    [[ -f $subdomain_dir/goaltdns.txt ]] && mv $subdomain_dir/goaltdns.txt $subdomain_dir/goaltdns.old
    
    goaltdns -l $subdomain_dir/combined_recursive.txt -w $brute_wordlist -o $subdomain_dir/goaltdns.txt

    my_diff $subdomain_dir/goaltdns.old $subdomain_dir/goaltdns.txt "goaltdns"

    ## Final Combination

    print_message "Final Combination..."
    
    ## Filter with scope regex if available
    if [[ $scope_regex ]]; then
        print_warning "Filtering out out-of-scope domains" 
        cat $subdomain_dir/goaltdns.txt $subdomain_dir/combined_recursive.txt | sort -u | grep -Ev "$scope_regex" > $subdomain_dir/final_subdomains.txt
    else
        cat $subdomain_dir/goaltdns.txt $subdomain_dir/combined_recursive.txt | sort -u > $subdomain_dir/final_subdomains.txt
    fi

    ## New Subdomains

    if [[ -f $subdomain_dir/final_subdomains_stripped.old ]]; then
        cat $subdomain_dir/final_subdomains_stripped.txt | anew $subdomain_dir/final_subdomains_stripped.old -d > $subdomain_dir/new_subdomains.txt
    else
        cat $subdomain_dir/final_subdomains_stripped.txt > $subdomain_dir/new_subdomains.txt
    fi

    ## Check for live subdomains

    print_task "Running 'httprobe' (looking for live subdomains)" "${red}-->${reset} ./$(realpath --relative-to="." "$subdomain_dir/live_subdomains.txt")"

    cat $subdomain_dir/new_subdomains.txt | probe | tee "$subdomain_dir/live_subdomains.txt"

    ## Count and output new subdomains

    new_subdomain_count=$(wc -l "$subdomain_dir/new_subdomains.txt" | cut -d ' ' -f 1)
    live_subdomain_count=$(wc -l "$subdomain_dir/live_subdomains.txt" | cut -d ' ' -f 1)

    send_to_discord "Discovered \`$new_subdomain_count\` **NEW** subdomains:" $subdomain_webhook "$subdomain_dir/new_subdomains.txt" 
    send_to_discord "Live subdomains (\`$live_subdomain_count\`):" $subdomain_webhook "$subdomain_dir/live_subdomains.txt" 
    
    print_message "Discoverd $new_subdomain_count NEW subdomains" "${red}-->${reset} ./$(realpath --relative-to="." "$subdomain_dir/new_subdomains.txt")"
    print_message "Live subdomains ($live_subdomain_count):"
    cat $subdomain_dir/live_subdomains.txt

    ## DNSReaper Subdomain Takeovers

    print_task "Running 'dnsreaper' (subdomain takeover detection)" "${red}-->${reset} ./$(realpath --relative-to="." "$subdomain_dir/dnsreaper-takeovers.json")"
    [[ -r "$subdomain_dir/dnsreaper-takeovers.json" ]] && mv "$subdomain_dir/dnsreaper-takeovers.json" "$subdomain_dir/dnsreaper-takeovers.old"

    dnsreaper file --filename "$subdomain_dir/live_subdomains.txt" --out-format json --out "$subdomain_dir/dnsreaper-takeovers.txt"

    if [[ -r "$subdomain_dir/dnsreaper-takeovers.old" ]]; then
        my_diff "$subdomain_dir/dnsreaper-takeovers.old" "$subdomain_dir/dnsreaper-takeovers.json" "DNSReaper (subdomain takeovers)" $subdomain_webhook
    elif [[ $(cat "$subdomain_dir/dnsreaper-takeovers.json") ]]; then
        print_message "Report of:" "DNSReaper"
        jq . "$subdomain_dir/dnsreaper-takeovers.json"
        send_to_discord "DNSReaper report:\n\`\`\`json\n$(jq . "$subdomain_dir/dnsreaper-takeovers.json")\n\`\`\`" $subdomain_webhook "$subdomain_dir/dnsreaper-takeovers.json"
    else
        print_warning "No findings from DNSReaper"
    fi
    
    ## Nuclei Subdomain Takeover

    print_task "Running 'nuclei -tags takeover' (subdomain takeover detection)" "${red}-->${reset} ./$(realpath --relative-to="." "$subdomain_dir/nuclei_takeovers.txt")"
    [[ -r "$subdomain_dir/nuclei_takeovers.txt" ]] && mv "$subdomain_dir/nuclei_takeovers.txt" "$subdomain_dir/nuclei_takeovers.old"

    nuclei -tags takeover -l "$subdomain_dir/live_subdomains.txt" -o "$subdomain_dir/nuclei_takeovers.txt"

    if [[ -r "$subdomain_dir/nuclei_takeovers.old" ]]; then
        my_diff "$subdomain_dir/nuclei_takeovers.old" "$subdomain_dir/nuclei_takeovers.txt" "Nuclei (subdomain takeovers)" $subdomain_webhook
    elif [[ $(cat "$subdomain_dir/nuclei_takeovers.txt") ]]; then
        print_message "Report from:" "Nuclei (-tags takeovers)"
        cat "$subdomain_dir/nuclei_takeovers.txt"
        send_to_discord "Nuclei (-tags takeovers) report:\n\`\`\`\n$(cat "$subdomain_dir/nuclei_takeovers.txt")\n\`\`\`" $subdomain_webhook "$subdomain_dir/nuclei_takeovers.txt"
    else
        print_warning "No findings from Nuclei"
    fi

    ## Time Taken

    end_seconds=$SECONDS
    execution_seconds=$((end_seconds - start_seconds))
    execution_time=$(date -u -d @${execution_seconds} +"%T")
    print_green "Completed Subdomain Recon" "(Took ${yellow}$execution_time${reset}) ${red}-->${reset} ./$(realpath --relative-to="." "$subdomain_dir/")"
    send_to_discord "**Completed** __Subdomain Recon__ in \`$execution_time\`\n- *Found \`$new_subdomain_count\` new subdomains (live: \`$live_subdomain_count\`)*" $logs_webhook
}

subdomain_screenshot() {

    print_announce "Taking Screenshots of Subdomains"
    start_seconds=$SECONDS

    ## Take The Screenshots

    if [[ -f $subdomain_dir/live_subdomains.txt && $(cat $subdomain_dir/live_subdomains.txt) ]]; then

        screenshots=($(ls $screenshot_dir/*.png 2> /dev/null))

        [[ -r $screenshot_dir/gowitness_db.sqlite3 ]] && rm $screenshot_dir/gowitness_db.sqlite3

        for screenshot in "${screesnhots[@]}"; do
            mv $screenshot_dir/*.png $screenshot_dir/old/
        done

        gowitness file -f $subdomain_dir/live_subdomains.txt --delay 3 --timeout 30 -P $screenshot_dir -D $screenshot_dir/gowitness_db.sqlite3
        
        screenshots=($(ls $screenshot_dir/*.png))

        if [[ $screenshot_webhook ]]; then
            for screenshot in "${screenshots[@]}"; do
                print_message "Uploading Screenshot:" "$(basename $screenshot)"
                url="$(basename $screenshot | sed -e "s/.png//g" -e "s/http-/http:\/\//g" -e "s/https-/https:\/\//g")"
                send_to_discord "Screenshot of \`$url\`:" "$screenshot_webhook" "$screenshot"
            done
        fi  
    else
        print_warning "No New Subdomains Found"
    fi

    ## Time Taken

    end_seconds=$SECONDS
    execution_seconds=$((end_seconds - start_seconds))
    execution_time=$(date -u -d @${execution_seconds} +"%T")
    print_green "Completed Screenshots of Subdomains" "(Took ${yellow}$execution_time${reset}${bold}) ${red}-->${reset} ./$(realpath --relative-to="." "$recon_dir/screenshots")"
    send_to_discord "**Completed** taking __Screenshots of Subdomains__ in \`$execution_time\`" $logs_webhook
}

fingerprint_recon() {

    print_announce "Fingerprint/Service Scanning"
    start_seconds=$SECONDS

    if [[ -f $subdomain_dir/new_subdomains.txt && $(cat $subdomain_dir/new_subdomains.txt) ]]; then
 
        ## WOHIS REPORT

        domains=($(awk -F "." '{print $(NF-1)"."$NF}' $subdomain_dir/new_subdomains.txt | sort -u))

        for url in "${domains[@]}"; do
            echo "==============>> $url WHOIS report <<=============="
            whois $url
            echo "\n\n\n"    
        done | tee $fingerprint_dir/new_whois_report.txt

        if [[ $fingerprint_webhook ]]; then
            print_message "Uploading:" "Whois Reports..."
            send_to_discord "**\`whois\`** report ($start_date)" $fingerprint_webhook "$fingerprint_dir/new_whois_report.txt"
        fi

        cat $fingerprint_dir/new_whois_report.txt >> $fingerprint_dir/whois_report.txt

        ## Extract IPs of URLs

        print_task "Extracting IP Addresses of Discovered Subdomains" "${red}-->${reset} ./$(realpath --relative-to="." "$fingerprint_dir/IPs.txt")"

        new_subdomains=($(cat $subdomain_dir/new_subdomains.txt))

        for url in "${new_subdomains[@]}"; do
            nslookup $url | grep "Address: " | head -1 | sed -e "s/Address:\ //"
        done | tee $fingerprint_dir/IPs.txt

        ## SHODAN

        print_task "Generating Shodan Report" "${red}-->${reset} ./$(realpath --relative-to="." "$fingerprint_dir/shodan_report.txt")"

        ips=($(cat $fingerprint_dir/IPs.txt))

        for i in "${!ips[@]}"; do
            echo -e "==============>> ${ips[$i]} (${new_subdomains[$i]}) report <<=============="
            shodan host "${ips[$i]}"
            echo -e "\n\n"
        done | tee $fingerprint_dir/new_shodan_report.txt

        if [[ $fingerprint_webhook ]]; then
            print_message "Uploading:" "Shodan Reports..."
            send_to_discord "**Shodan** report ($start_date)" $fingerprint_webhook "$fingerprint_dir/new_shodan_report.txt"
        fi

        cat $fingerprint_dir/new_shodan/report.txt >> $fingerprint_dir/shodan_report.txt

        ## NMAP

        print_task "Running Nmap Scans" "${red}-->${reset} ./$(realpath --relative-to="." "$fingerprint_dir/nmap_scans.txt")"

        nmap -p 0-10000 -sV -iL $fingerprint_dir/IPs.txt -oG nmap_scans_temp.txt

        sed '/#\ Nmap/d' nmap_scans_temp.txt | grep -v "Status: " > new_nmap_scans.txt
        rm nmap_scans_temp.txt

        if [[ $fingerprint_webhook ]]; then
            print_message "Uploading:" "Nmap Scans..."
            send_to_discord "**\`nmap\`** report ($start_date)" $fingerprint_webhook "$fingerprint_dir/new_nmap_scan.txt"
        fi

        cat new_nmap_scans.txt >> nmap_scans.txt

        ## Time Taken

        end_seconds=$SECONDS
        execution_seconds=$((end_seconds - start_seconds))
        execution_time=$(date -u -d @${execution_seconds} +"%T")
        print_green "Completed Fingerprint/Service Scan of Subdomains" "(Took ${yellow}$execution_time${reset}${bold}) ${red}-->${reset} ./$(realpath --relative-to="." "$recon_dir/screenshots")" 
        send_to_discord "**Completed** __Fingerprint/Service scanning__ in \`$execution_time\`" $logs_webhook       
    else
        print_warning "No New Subdomains Found"
    fi
}

deep_domain_recon() {

    print_announce "Deep Domain Recon"
    start_seconds=$SECONDS
    
    if [[ "${deep_domains[*]}" ]]; then
        start_seconds=$SECONDS
        
        for i in "${!deep_domains[@]}"; do

            domain="${deep_domains[$i]}"
            wordlist="${fuzz_wordlist[$i]}"
            [[ -d $deep_dir/$domain ]] || mkdir $deep_dir/$domain
            
            ## Wayback urls

            print_task "Running 'waybackurls' on '$domain'" "${red}-->${reset} ./$(realpath --relative-to="." "$deep_dir/$domain/waybackurls.txt")"
            [[ -f $deep_dir/$domain/waybackurls.txt ]] && mv $deep_dir/$domain/waybackurls.txt $deep_dir/$domain/waybackurls.old
        
            waybackurls $domain | tee $deep_dir/$domain/waybackurls.txt

            [[ -r $deep_dir/$domain/waybackurls.txt && $(cat $deep_dir/$domain/waybackurls.txt) ]] || print_warning "No findings from 'waybackurls'"

            my_diff $deep_dir/$domain/waybackurls.old $deep_dir/$domain/waybackurls.txt "waybackurls" $deep_domain_webhook

            ## Feroxbuster dir brute-forcing

            print_task "Running 'feroxbuster' on '$domain'" "${red}-->${reset} ./$(realpath --relative-to="." "$deep_dir/$domain/feroxbuster.txt")"
            [[ -f $deep_dir/$domain/feroxbuster.txt ]] && mv $deep_dir/$domain/feroxbuster.txt $deep_dir/$domain/feroxbuster.old
        
            feroxbuster -u $domain -t 20 -L 20 -w ${fuzz_wordlist[$i]} -o $deep_dir/$domain/feroxbuster.txt
            echo ""

            my_diff $deep_dir/$domain/feroxbuster.old $deep_dir/$domain/feroxbuster.txt "feroxbuster" $deep_domain_webhook

            ## Combine files

            print_message "Combining Findings"

            sort -u $deep_dir/$domain/feroxbuster.txt $deep_dir/$domain/waybackurls.txt | extract_url > $deep_dir/$domain/combined_deep.txt
            cat $deep_dir/$domain/combined_deep.txt | probe | tee $deep_dir/$domain/combined_deep_live.txt
            findings=($(cat $deep_dir/$domain/combined_deep_live.txt))

            ## Scan js files for leaks

            print_task "Runing 'secretfinder' on '$domain'" "${red}-->${reset} ./$(realpath --relative-to="." "$deep_dir/$domain/secretfinder.html")"
            [[ -f $deep_dir/$domain/secretfinder.html ]] && mv $deep_dir/$domain/secretfinder.html $deep_dir/$domain/secretfinder.old 

            [[ -d $deep_dir/$domain/secretfinder ]] || mkdir $deep_dir/$domain/secretfinder 

            for url in "${findings[@]}"; do

                filename=$(echo $url | sed -e "s/https:\/\///g" -e "s/http:\/\///g")
                sudo -u kali secretfinder -i $url -e -o $deep_dir/$domain/secretfinder/${filename}.html
            
            done

            my_diff $deep_dir/$domain/secretfinder.old $deep_dir/$domain/secretfinder.html "SecretFinder.py" $deep_domain_webhook

        done

        ## Time Taken

        end_seconds=$SECONDS
        execution_seconds=$((end_seconds - start_seconds))
        execution_time=$(date -u -d @${execution_seconds} +"%T")
        print_green "Completed Deep Recon of Domains" "(Took ${yellow}$execution_time${reset}${bold}) ${red}-->${reset} ./$(realpath --relative-to="." "$deep_dir")"
        send_to_discord "**Completed** __Deep Recon of URLs__ in \`$execution_time\`" $logs_webhook
    else
        print_warning "No Deep Domains Defined"
    fi
    
}

leaks() {

    print_announce "Scanning for Leaks in Github/Gitlab Repositories"
    start_seconds=$SECONDS

    platforms=("GitHub" "GitLab")

    for platform in "${platforms[@]}"; do
        if [[ $platform = "GitHub" ]]; then
            g_leak_path=$github_leaks_dir
            recon_array=($github_recon)
            token=$ghtoken
        else
            g_leak_path=$gitlab_leaks_dir
            recon_array=($gitlab_recon)
            token=$gltoken
        fi

        if [[ $recon_array ]]; then
        
            users=()
            for url in "${recon_array[@]}"; do
                users+=($(echo $url | sed -e "s/https:\/\///g" -e "s/http:\/\///g" | cut -d '/' -f 2 | sort -u))
            done

            ## Gitrob

            if [[ $token ]]; then
                for user in "${users[@]}"; do
                    print_task "Running 'gitrob' on $platform user '$user'" "${red}-->${reset} ./$(realpath --relative-to=. $g_leak_path/)/gitrob_${user}.json"
                    [[ -r ${g_leak_path}/gitrob_${user}.json ]] && mv ${g_leak_path}/gitrob_${user}.json ${g_leak_path}/gitrob_${user}.json.old

                    cd $(dirname $(realpath $(which gitrob)))

                    if [[ $platform = "GitHub" ]]; then
                        gitrob -save ${g_leak_path}/gitrob_${user}.json -mode 2 -exit-on-finish -github-access-token $token $user
                    else
                        gitrob -save ${g_leak_path}/gitrob_${user}.json -mode 2 -exit-on-finish -gitlab-access-token $token $user
                    fi
                    
                    my_diff ${g_leak_path}/gitrob_${user}.json.old ${g_leak_path}/gitrob_${user}.json "gitrob ($user)" $leaks_webhook
                    
                    cd - &> /dev/null

                    ## Gitrob Findings

                    findings=$([[ -r ${g_leak_path}/gitrob_${user}.json ]] && jq .Findings ${g_leak_path}/gitrob_${user}.json)

                    if [[ ! $findings || $findings = "null" ]]; then
                        print_warning "No findings from 'gitrob'"
                    else
                        print_task "'gitrob' findings on $platform user '$user'" "${red}-->${reset} ./$(realpath --relative-to=. "${g_leak_path}"/)/gitrob_${user}_findings.json"

                        [[ -r ${g_leak_path}/gitrob_${user}_findings.json ]] && mv "${g_leak_path}/gitrob_${user}_findings.json" "${g_leak_path}/gitrob_${user}_findings.json.old"
                        echo $findings | jq . | tee ${g_leak_path}/gitrob_${user}_findings.json

                        my_diff ${g_leak_path}/gitrob_${user}_findings.json.old ${g_leak_path}/gitrob_${user}_findings.json "gitrob ($user)" $leaks_webhook
                    fi
                done

                ## Trufflehog

                for repo in "${recon_array[@]}"; do
                    filename="$(echo trufflehog_$(echo $repo | awk -F "/" '{print $(NF-1)"_"$NF}')).json"

                    print_task "Running 'trufflehog' on $platform repo '$repo'" "${red}-->${reset} ./$(realpath --relative-to=. $g_leak_path/)/$filename"
                    [[ -r $g_leak_path/$filename ]] && mv "$g_leak_path/$filename" "$g_leak_path/${filename}.old"

                    if [[ $platform = "GitHub" ]]; then
                        trufflehog_report=$(trufflehog github --token=$token --repo=$repo -j | jq .)
                    else
                        trufflehog_report=$(trufflehog gitlab --token=$token --repo=$repo -j | jq .)
                    fi

                    if [[ ! $trufflehog_report || $trufflehog_report = "null" ]]; then
                        print_warning "No report from trufflehog"
                    else
                        echo "$trufflehog_report" | jq . | tee "$g_leak_path/$filename"
                        my_diff "${g_leak_path}/${filename}.old" "${g_leak_path}/$filename" "trufflehog ($repo)" $leaks_webhook
                    fi
                done
            else
                print_error "No $platform token defined"
            fi
        else
            print_warning "No $platform repositories provided"
        fi
    done

    ## Time Taken

    end_seconds=$SECONDS
    execution_seconds=$((end_seconds - start_seconds))
    execution_time=$(date -u -d @${execution_seconds} +"%T")
    print_green "Completed Scan for Leaks" "(Took ${yellow}$execution_time${reset}${bold}) ${red}-->${reset} ./$(realpath --relative-to="." "$leaks_dir")"
    send_to_discord "**Completed** __Search for Leaks__ in \`$execution_time\`" $logs_webhook
}

init() {
    print_banner
    print_info

    ## Check For Requirements
    
    if [[ ! "$input_target" ]]; then
        print_error "Missing target (-t|-target)"
    elif [[ ! "$input_ghtoken" ]]; then
        print_error "Missing GitHub Token (-ght|-github-token)"
    fi
    

    if [[ ! "$input_path" ]]; then
        path=$(realpath .)
    else
        path=$input_path
    fi

    org=$(echo $input_target | cut -d '.' -f 1)

    if ! [[ $input_target =~ ^[a-zA-Z0-9.-]+\.[a-z]{2,}$ ]]; then
         print_error "Please provide only a base domain, not a subdomain or a URL"       
    fi

    ## Brute Wordlist


    if [[ ! "$input_brute_wordlist" ]]; then
        if [[ -r "/usr/share/seclists/Discovery/DNS/namelist.txt" ]]; then
            brute_wordlist="/usr/share/seclists/Discovery/DNS/namelist.txt"
        else
            print_error "Default subdomain brute force wordlist not found, please provide one (-b -brute-wordlists)"
        fi
    else
        while read -r wordlist; do
            [[ -r $wordlist ]] || print_error "Can't read file '$wordlist'"
        done < <(echo $input_brute_wordlist | sed -e "s/\"//g" -e "s/,/\n/g")

        brute_wordlist=$(echo $input_brute_wordlist | sed 's/,/",\ "/g')
    fi

    ## Custom Attacks

    if [[ $input_custom_task ]]; then
        while read -r attack; do
            match=0
            for dtasks in ${default_tasks[*]}; do
                [[ $dtasks = "$attack" ]] && match=1
            done
            [[ $match = 1 ]] || print_error "Unknowon attack '$attack'"
        done < <(echo $input_custom_task | sed "s/,/\n/g")
        attack_method_json=$(echo \"$input_custom_task\" | sed "s/,/\",\ \"/g")
    else
        attack_method_json=$(echo \"${default_tasks[*]}\" | sed "s/\ /\",\ \"/g")
    fi

    ## Webhooks

    if ! [[ $input_subdomain_webhook && $input_screenshot_webhook && $input_fingerprint_webhook && $input_deep_domain_webhook && $input_leaks_webhook && $input_logs_webhook ]] && [[ $input_subdomain_webhook || $input_screenshot_webhook || $input_fingerprint_webhook || $input_deep_domain_webhook || $input_leaks_webhook || $input_logs_webhook ]]; then
        print_error "Must provide ALL webhook URLs (subdomain, screenshot, fingerprint, deep_domain_recon, leaks, logs)"
    fi

    ## GitHub Recon

    if [[ $input_github_recon ]]; then
        github_recon_json=$(echo \"$input_github_recon\" | sed "s/,/\",\ \"/g")
    fi
    
    ## GitLab Recon

    if [[ $input_gitlab_recon && $input_gltoken ]]; then
        gitlab_recon_json=$(echo \"$input_gitlab_recon\" | sed "s/,/\",\ \"/g")
    elif [[ $input_gitlab_recon ]] && ! [[ $input_gltoken ]]; then
        print_error "Enumeration on GitLab Repositories requires a GitLab Access Token (-glt -gitlab-token)"
    fi

    ## Deep Domains

    if [[ ${input_deep_domains[*]} && ${input_fuzz_wordlist[*]} ]]; then
        deep_domains_json="$(echo "$(for i in "${!input_deep_domains[@]}"; do
                                 echo -n "{\"domain\": \"${input_deep_domains[$i]}\",\"wordlist\": \"${input_fuzz_wordlist[$i]}\"}"
                             done)" | sed "s/}{/},{/g")"
    fi

    ## Create Directories

    recon_dir="$path/${org}_recon"
    
    [[ -d "$recon_dir" ]] || mkdir "$recon_dir"
    [[ -d "$recon_dir/subdomains" ]] || mkdir "$recon_dir/subdomains"
    [[ -d "$recon_dir/subdomains/old" ]] || mkdir "$recon_dir/subdomains/old"

    [[ -d "$recon_dir/screenshots" ]] || mkdir "$recon_dir/screenshots"
    [[ -d "$recon_dir/screenshots/old" ]] || mkdir "$recon_dir/screenshots/old"

    [[ -d "$recon_dir/logs" ]] || mkdir "$recon_dir/logs"

    [[ -d "$recon_dir/leaks" ]] || mkdir "$recon_dir/leaks"
    [[ -d "$recon_dir/leaks/old" ]] || mkdir "$recon_dir/leaks/old"

    [[ -d "$recon_dir/leaks/github" ]] || mkdir "$recon_dir/leaks/github"
    [[ -d "$recon_dir/leaks/github/old" ]] || mkdir "$recon_dir/leaks/github/old"

    [[ -d "$recon_dir/leaks/gitlab" ]] || mkdir "$recon_dir/leaks/gitlab"
    [[ -d "$recon_dir/leaks/gitlab/old" ]] || mkdir "$recon_dir/leaks/gitlab/old"

    [[ -d "$recon_dir/deep_domains" ]] || mkdir "$recon_dir/deep_domains"

    [[ -d "$recon_dir/fingerprint" ]] || mkdir "$recon_dir/fingerprint"
    [[ -d "$recon_dir/fingerprint/old" ]] || mkdir "$recon_dir/fingerprint/old"

    subdomain_dir="${recon_dir}/subdomains"
    screenshot_dir="${recon_dir}/screenshot"
    logs_dir="${recon_dir}/logs"
    leaks_dir="${recon_dir}/leaks"
    github_leaks_dir="${recon_dir}/leaks/gitlab"
    gitlab_leaks_dir="${recon_dir}/leaks/github"
    deep_dir="${recon_dir}/deep_domains"
    fingerprint_dir="${recon_dir}/fingerprint"
    config_file="${recon_dir}/${org}_config.json"

    ## Create JSON File
    
    jq -n "{
            config: {
                    target: \"$input_target\", 
                    recon_path: \"$recon_dir\",
                    scope_regex: \"$input_scope_regex\"
                    subdomain_brute_wordlist: [ 
                        \"$brute_wordlist\" 
                    ], 
                    deep_domains: [ 
                        $deep_domains_json
                    ], 
                    git: { 
                        token: { 
                            github: \"$input_ghtoken\",
                            gitlab: \"$input_gltoken\" 
                        }, 
                        github_recon: [ 
                            $github_recon_json
                        ], 
                        gitlab_recon: [ 
                            $gitlab_recon_json
                        ]
                    },
                    attack_method: [ 
                        $attack_method_json
                    ],
                    webhooks: {
                        subdomain: \"$input_subdomain_webhook\",
                        screenshot: \"$input_screenshot_webhook\",
                        fingerprint: \"$input_fingerprint_webhook\",
                        deep_domain: \"$input_deep_domain_webhook\",
                        leaks: \"$input_leaks_webhook\",
                        logs: \"$input_logs_webhook\"
                    }
                }
            }" > ${config_file}.new


    if [[ -f $config_file ]]; then
        if [[ $(diff "$config_file" "${config_file}.new") = "" ]]; then 
            print_warning "An ${bold}identical${reset}${italic} configuration file exists (${underline}./$(realpath --relative-to=. $config_file)${reset}${italic}), overwrite?"
        else 
            print_warning "A configuration file exists (${underline}${config_file}${reset}${italic}), overwrite?"
        fi

        prompt "[Y/N]:"

        case $userinput in
            y|Y)
                print_warning "Overwriting..."
                mv "${config_file}.new" "${config_file}"
                ;;
            *)
                print_warning "Not overwriting..."
                ;;
        esac
    else
        mv "${config_file}.new" "${config_file}"
    fi

    print_message "JSON Configuration"

    jq . $config_file
}

config() {
    print_banner
    print_info
    init_vars

    ## Check For Config File

    if [[ ! $config_file ]]; then
        print_error "Please provide a config file (-c|-config-file)"
    fi

    ## Make sure nano is standalone

    if [[ $input_target || $input_ghtoken || $input_deep_domains || $input_fuzz_wordlist || $input_brute_wordlist || $input_github_recon || $input_attack_method ]] && [[ $manual ]]; then
        print_error "-m|-manual is a standalone flag"
    fi

    ## Create directories if aren't there

    [[ -d "$recon_dir/subdomains" ]] || mkdir "$recon_dir/subdomains"
    [[ -d "$recon_dir/subdomains/old" ]] || mkdir "$recon_dir/subdomains/old"

    [[ -d "$recon_dir/screenshots" ]] || mkdir "$recon_dir/screenshots"
    [[ -d "$recon_dir/screenshots/old" ]] || mkdir "$recon_dir/screenshots/old"

    [[ -d "$recon_dir/logs" ]] || mkdir "$recon_dir/logs"

    [[ -d "$recon_dir/leaks" ]] || mkdir "$recon_dir/leaks"
    [[ -d "$recon_dir/leaks/old" ]] || mkdir "$recon_dir/leaks/old"

    [[ -d "$recon_dir/leaks/github" ]] || mkdir "$recon_dir/leaks/github"
    [[ -d "$recon_dir/leaks/github/old" ]] || mkdir "$recon_dir/leaks/github/old"

    [[ -d "$recon_dir/leaks/gitlab" ]] || mkdir "$recon_dir/leaks/gitlab"
    [[ -d "$recon_dir/leaks/gitlab/old" ]] || mkdir "$recon_dir/leaks/gitlab/old"

    [[ -d "$recon_dir/deep_domains" ]] || mkdir "$recon_dir/deep_domains"

    [[ -d "$recon_dir/fingerprint" ]] || mkdir "$recon_dir/fingerprint"
    [[ -d "$recon_dir/fingerprint/old" ]] || mkdir "$recon_dir/fingerprint/old"

    ## Create a Temp Config File

    cp $config_file /tmp/temp_$(basename ${config_file})
    tmp_config_file=/tmp/temp_$(basename ${config_file})

    ## Edit manually

    if [[ $manual ]]; then
        if [[ $input_editor ]]; then
            if [[ $(which $input_editor) ]]; then
                $input_editor $tmp_config_file
            else
                print_error "Unknown command '$input_editor'"
            fi
        else
            nano $tmp_config_file
        fi
    fi

    ## Change/Define Webhooks

    if [[ $input_subdomain_webhook ]]; then
        jq ".config.webhooks.subdomain = \"$input_subdomain_webhook\"" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi
    
    if [[ $input_screenshot_webhook ]]; then
        jq ".config.webhooks.screenshot = \"$input_screenshot_webhook\"" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi
    
    if [[ $input_fingerprint_webhook ]]; then
        jq ".config.webhooks.fingerprint = \"$input_fingerprint_webhook\"" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi
    
    if [[ $input_deep_domain_webhook ]]; then
        jq ".config.webhooks.deep_domain = \"$input_deep_domain_webhook\"" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi
    
    if [[ $input_leaks_webhook ]]; then
        jq ".config.webhooks.leaks = \"$input_leaks_webhook\"" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi
    
    if [[ $input_logs_webhook ]]; then
        jq ".config.webhooks.logs = \"$input_logs_webhook\"" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi

    ## Change Target

    if [[ $input_target ]]; then
        jq ".config.target = \"$input_target\"" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi
   
    ## Change Target

    if [[ $input_scope_regex ]]; then
        jq --arg regex "$input_scope_regex" ".config.scope_regex = \$regex" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi

    ## Change GitHub Token

    if [[ $input_ghtoken ]]; then
        jq ".config.git.token.github = \"$input_ghtoken\"" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi

    ## Change GitHub Token

    if [[ $input_gltoken ]]; then
        jq ".config.git.token.gitlab = \"$input_gltoken\"" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi

    ## Add Fuzz Domains

    if [[ "${input_deep_domains[*]}" && "${input_fuzz_wordlist[*]}" ]]; then

        for i in "${!input_deep_domains[@]}"; do
            jq ".config.deep_domains += [{
                                            domain: \"${input_deep_domains[$i]}\",
                                            wordlist: \"${input_fuzz_wordlist[$i]}\" 
                                        }]" "${tmp_config_file}" > "${tmp_config_file}.tmp"
            mv "${tmp_config_file}.tmp" "${tmp_config_file}"
        done
    fi

    ## Add Brute-Force Wordlists

    if [[ $input_brute_wordlist ]]; then

        while read -r wordlist; do
            [[ -r $wordlist ]] || print_error "Can't read file '$wordlist'"
        done < <(echo $input_brute_wordlist | sed -e "s/\"//g" -e "s/,/\n/g")

        brute_wordlists=$(echo $input_brute_wordlist | sed 's/,/",\ "/g')
    
        jq ".config.subdomain_brute_wordlist += [ \"$brute_wordlists\" ]" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi

    ## Add GitHub Repo For Recon

    if [[ $input_github_recon ]]; then
        
        github_recon_json=$(echo \"$input_github_recon\" | sed "s/,/\",\ \"/g")

        jq ".config.git.github_recon += [ $github_recon_json ]" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi
    
    ## Add GitLab Repo For Recon

    if [[ $input_gitlab_recon ]]; then

        gitlab_recon_json=$(echo \"$input_gitlab_recon\" | sed "s/,/\",\ \"/g")

        jq ".config.git.gitlab_recon += [ $gitlab_recon_json ]" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi

    ## Change Attack Method

    if [[ $input_attack_method ]]; then

        if [[ $input_attack_method = 'default' ]]; then
            attack_method_json=$(echo \"${input_default_tasks[*]}\" | sed "s/\ /\",\ \"/g")
        else
            while read -r attack; do
                    match=0
                for dtasks in ${default_tasks[*]}; do
                    [[ $dtasks = "$attack" ]] && match=1
                done
                [[ $match = 1 ]] || print_error "Unknowon attack '$attack'"
            done < <(echo $input_attack_method | sed "s/,/\n/g")
            attack_method_json=$(echo \"$input_attack_method\" | sed "s/,/\",\ \"/g")
        fi

        jq ".config.attack_method = [$attack_method_json]" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi 
    
    if [[ $(jq . $tmp_config_file) ]]; then
        print_message "Current JSON Configuration"
        mv $tmp_config_file $config_file
        jq . $config_file
    else
        print_error "Error in JSON syntax, not writing changes" no_exit
    fi
}

recon() {
    for attack in "${attack_method[@]}"; do
        if [[ $attack = "subdomain" ]]; then
            subdomain_recon
        elif [[ $attack = "screenshot" ]]; then
            subdomain_screenshot
        elif [[ $attack = "fingerprint" ]]; then
            fingerprint
        elif [[ $attack = "deep_domains" ]]; then
            deep_domain_recon
        elif [[ $attack = "leaks" ]]; then
            leaks
        fi
    done
}

reports() {

    print_banner
    print_info
    init_vars

    print_message "Available reports:"
    for available_report in "${attack_method[@]}"; do
        print_minor "$available_report"
    done

    echo ""

    if [[ $report ]]; then
            if [[ $report = "subdomain" ]]; then
                dir=$subdomain_dir
                files=($(find $subdomain_dir -not -path "*.old" -type f))
                for file in "${files[@]}"; do
                    [[ $(cat $file) = "" ]] || available_files+=($file)
                done
            elif [[ $report = "fingerprint" ]]; then
                dir=$fingerprint_dir
                files=($(find $fingerprint_dir -not -path "*.old" -type f))
                for file in "${files[@]}"; do
                    [[ $(cat $file) = "" ]] || available_files+=($file)
                done
            elif [[ $report = "deep_domains" ]]; then
                dir=$deep_dir
                files=($(find $deep_dir -not -path "*.old" -type f))
                for file in "${files[@]}"; do
                    [[ $(cat $file) = "" ]] || available_files+=($file)
                done
            elif [[ $report = "leaks" ]]; then
                dir=$leaks_dir
                files=($(find $leaks_dir -not -path "*.old" -type f))
                for file in "${files[@]}"; do
                    [[ $(cat $file) = "" ]] || available_files+=($file)
                done
            else
                print_error "Unknown report: $report"
            fi

        for file in "${available_files[@]}"; do
            available_subreports+=($(echo $file | sed "s@$dir\/@@"))
        done

        if [[ $available_subreports ]]; then
            print_message "Available sub-reports:"
            for sr in "${available_subreports[@]}"; do
                print_minor "$sr"
            done

            if [[ $subreport ]]; then 
                
                for r in "${available_subreports[@]}"; do
                    [[ $r = $subreport ]] && found=1
                done
                
                echo ""

                [[ $found = 1 ]] || print_error "Unavailable sub-report provided: $subreport"

                print_message "Report:" "$subreport"
                echo ""

                if [[ $subreport = *".json"* ]]; then
                    jq . $dir/$subreport
                else 
                    bat -Pn $dir/$subreport
                fi
            fi
        else
            print_warning "No sub-reports for $report enumeration"
        fi
    fi
}

init_vars() {
    [[ $config_file ]] || print_error "Missing config file (-c|-config-file)"

    target=$(jq -r '.config.target' $config_file)

    scope_regex=$(jq -r '.config.scope_regex' $config_file)
    brute_wordlists=($(jq -r '.config.subdomain_brute_wordlist[]' $config_file))

    ghtoken=$(jq -r '.config.git.token.github' $config_file)
    gltoken=$(jq -r '.config.git.token.gitlab' $config_file)
    github_recon=($(jq -r '.config.git.github_recon[]' $config_file))
    gitlab_recon=($(jq -r '.config.git.gitlab_recon[]' $config_file))

    deep_domains=($(jq -r '.config.deep_domains[].domain' $config_file))
    fuzz_wordlist=($(jq -r '.config.deep_domains[].wordlist' $config_file))

    attack_method=($(jq -r '.config.attack_method[]' $config_file))
    recon_dir=$(jq -r '.config.recon_path' $config_file)

    subdomain_webhook=$(jq -r '.config.webhooks.subdomain' $config_file)
    screenshot_webhook=$(jq -r '.config.webhooks.screenshot' $config_file)
    fingerprint_webhook=$(jq -r '.config.webhooks.fingerprint' $config_file)
    deep_domain_webhook=$(jq -r '.config.webhooks.deep_domain' $config_file)
    leaks_webhook=$(jq -r '.config.webhooks.leaks' $config_file)
    logs_webhook=$(jq -r '.config.webhooks.logs' $config_file)

    script_home=$(dirname $(realpath $0))
    org=$(echo $target | cut -d '.' -f 1)

    subdomain_dir="${recon_dir}/subdomains"
    screenshot_dir="${recon_dir}/screenshots"
    logs_dir="${recon_dir}/logs"
    leaks_dir="${recon_dir}/leaks"
    github_leaks_dir="${recon_dir}/leaks/github"
    gitlab_leaks_dir="${recon_dir}/leaks/gitlab"
    fingerprint_dir="${recon_dir}/fingerprint"
    deep_dir="${recon_dir}/deep_domains"

    if ! [[ -d $subdomain_dir || -d $screenshot_dir || $deep_dir || -d $logs_dir || -d $leaks_dir || -d $fingerprint_dir || -d $github_leaks_dir || -d $gitlab_leaks_dir ]]; then
        print_error "Please run 'init' function"
    fi
}

_test() {
    print_announce "Test Run"   
    start_seconds=$SECONDS
    # echo $subdomain_dir
    sleep 10
    end_seconds=$SECONDS
    execution_seconds=$((end_seconds - start_seconds))
    execution_time=$(date -u -d @${execution_seconds} +"%T")
    print_green "Test completed in ${yellow}$execution_time${reset}" "${red}-->${reset} ./tmp/example.txt"
}

func_wrapper() {
    command=$1
    scan_name=$2

    init_vars

    start_date=$(my_date)
    logfile="$logs_dir/$scan_name ($start_date).log"

    wait_for_internet
    
    send_to_discord "**STARTING RECON IN MODE:** \`$mode\`" $logs_webhook
    
    {
    print_banner
    print_info
    $command

    if [[ $logs_webhook ]]; then
        print_message "Uploading Logs..."
    fi
    } |& tee "$logfile"
    
    send_to_discord "Log file for **$scan_name** scan at: \`$start_date\`" "$logs_webhook" "$logfile"
}

flags() {

    [[ "$#" -eq 0 ]] && help

    case $1 in
        init)
            mode="init"
            shift
            while [[ "$1" != "" ]]; do
                case $1 in
                    -t|-target)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_target="$1"
                        else
                            print_error "-t|-target requires an argument!"
                        fi
                        shift
                        ;;
                    -ght|-github-token)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_ghtoken="$1"
                        else
                            print_error "-ght|-github-token requires an argument!"
                        fi
                        shift
                        ;;
                    -ghr|-github-recon)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_github_recon="$1"
                        else
                            print_error "-ghr|-github-recon requires an argument!"
                        fi
                        shift
                        ;;
                    -glt|-gitlab-token)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_gltoken="$1"
                        else
                            print_error "-glt|-gitlab-token requires an argument!"
                        fi
                        shift
                        ;;
                    -glr|-gitlab-recon)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_gitlab_recon="$1"
                        else
                            print_error "-glr|-gitlab-recon requires an argument!"
                        fi
                        shift
                        ;;
                    -ws|-subdomain-webhook)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_subdomain_webhook="$1"
                        else
                            print_error "-ws|-subdomain-webhook requires an argument!"
                        fi
                        shift
                        ;;
                    -wf|-fingerprint-webhook)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_fingerprint_webhook="$1"
                        else
                            print_error "-wf|-fingerprint-webhook requires an argument!"
                        fi
                        shift
                        ;;
                    -wd|-deep-domain-webhook)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_deep_domain_webhook="$1"
                        else
                            print_error "-wd|-deep-domain-webhook requires an argument!"
                        fi
                        shift
                        ;;
                    -wl|-leaks-webhook)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_leaks_webhook="$1"
                        else
                            print_error "-wl|-leaks-webhook requires an argument!"
                        fi
                        shift
                        ;;
                    -wg|-logs-webhook)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_logs_webhook="$1"
                        else
                            print_error "-wg|-logs_webhook requires an argument!"
                        fi
                        shift
                        ;;
                    -wc|-screenshots-webhook)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_screenshot_webhook="$1"
                        else
                            print_error "-wc|-screenshots-webhook requires an argument!"
                        fi
                        shift
                        ;;
                    -b|-brute-wordlists)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_brute_wordlist="$1"
                        else
                            print_error "-b|-brute-wordlist requires a wordlist file!"
                        fi
                        shift
                        ;;
                    -p|-path)
                        shift
                        if [[ "$1" != -?* && -d "$1" ]]; then
                            input_path="$(realpath $1)"
                        else
                            print_error "-p|-path requires a valid path!"
                        fi
                        shift
                        ;;
                    -ct|-custom-tasks)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_custom_task="$1"
                        else
                            print_error "-ct|-custom-tasks requires an argument!"
                        fi
                        shift
                        ;;
                    -sr|-scope-regex)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_scope_regex="$1"
                        else
                            print_error "-sr|-scope-regex requires an argument!"
                        fi
                        shift
                        ;;
                    -d|-deep-domains)
                        shift
                        if [[ "$1" && -r "$2" ]]; then
                            input_deep_domains+=("$1")
                            input_fuzz_wordlist+=("$2")
                        else
                            print_error "-d|-deep-domains requires a domain and a valid path!"
                        fi
                        shift 2
                        ;;
                    -h|-help)
                        help init
                        ;;
                    *)
                        print_error "Unknown option '$1'"
                        ;;
                esac        
            done
            ;;
        config)
            mode="config"
            shift
            while [[ "$1" != "" ]]; do
                case $1 in
                    -t|-target)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_target="$1"
                        else
                            print_error "-t|-target requires an argument!"
                        fi
                        shift
                        ;;
                    -d|-deep-domains)
                        shift
                        if [[ "$1" && -r "$2" ]]; then
                            input_deep_domains+=("$1")
                            input_fuzz_wordlist+=("$2")
                        else
                            print_error "-d|-deep-domains requires a domain and a valid path!"
                        fi
                        shift 2
                        ;;
                    -sr|-scope-regex)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_scope_regex="$1"
                        else
                            print_error "-sr|-scope-regex requires an argument!"
                        fi
                        shift
                        ;;
                    -ght|-github-token)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_ghtoken="$1"
                        else
                            print_error "-ght|-github-token requires an argument!"
                        fi
                        shift
                        ;;
                    -ghr|-github-recon)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_github_recon="$1"
                        else
                            print_error "-ghr|-github-recon requires an argument!"
                        fi
                        shift
                        ;;
                    -glt|-gitlab-token)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_gltoken="$1"
                        else
                            print_error "-glt|-gitlab-token requires an argument!"
                        fi
                        shift
                        ;;
                    -glr|-gitlab-recon)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_gitlab_recon="$1"
                        else
                            print_error "-glr|-gitlab-recon requires an argument!"
                        fi
                        shift
                        ;;
                    -b|-brute-wordlist)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_input_brute_wordlist="$1"
                        else
                            print_error "-b|-brute-wordlist requires a wordlist file!"
                        fi
                        shift
                        ;;
                    -a|-attack-method)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_attack_method="$1"
                        else
                            print_error "-a|-attack-method requires a valid path!"
                        fi
                        shift
                        ;;
                    -c|-config-file)
                        shift
                        if [[ -r "$1" ]]; then
                            config_file="$(realpath $1)"
                        else
                            print_error "-c|-config-file requires a valid config file!"
                        fi
                        shift
                        ;;
                    -ws|-subdomain-webhook)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_subdomain_webhook="$1"
                        else
                            print_error "-ws|-subdomain-webhook requires an argument!"
                        fi
                        shift
                        ;;
                    -wf|-fingerprint-webhook)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_fingerprint_webhook="$1"
                        else
                            print_error "-wf|-fingerprint-webhook requires an argument!"
                        fi
                        shift
                        ;;
                    -wd|-deep-domain-webhook)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_deep_domain_webhook="$1"
                        else
                            print_error "-wd|-deep-domain-webhook requires an argument!"
                        fi
                        shift
                        ;;
                    -wl|-leaks-webhook)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_leaks_webhook="$1"
                        else
                            print_error "-wl|-leaks_webhook requires an argument!"
                        fi
                        shift
                        ;;
                    -wg|-logs-webhook)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_logs_webhook="$1"
                        else
                            print_error "-wg|-logs_webhook requires an argument!"
                        fi
                        shift
                        ;;
                    -wc|-screenshots-webhook)
                        shift
                        if [[ "$1" != -?* ]]; then
                            input_screenshot_webhook="$1"
                        else
                            print_error "-wc|-screenshots-webhook requires an argument!"
                        fi
                        shift
                        ;;
                    -m|-manual)
                        manual='true'
                        shift
                        if [[ $1 != -?* ]]; then
                            input_editor="$1"
                        fi
                        shift
                        ;;
                    -h|-help)
                        help config
                        ;;
                    *)
                        print_error "Unknown option '$1'"
                        ;;
                esac        
            done
            ;;    
        recon)
            mode="recon"
            shift
            while [[ "$1" != "" ]]; do
                case $1 in
                    -c|-config-file)
                        shift
                        if [[ -r "$1" ]]; then
                            config_file="$1"
                        else
                            print_error "-c|-config-file requires a valid config file!"
                        fi
                        ;;
                    -h|-help)
                        help recon
                        ;;
                    *)
                        print_error "Unknown option '$1'"
                        ;;
                esac
                shift
            done
            ;;
        subdomain)
            mode="subdomain"
            shift
            while [[ "$1" != "" ]]; do
                case $1 in
                    -c|-config-file)
                        shift
                        if [[ -r "$1" ]]; then
                            config_file="$1"
                        else
                            print_error "-c|-config-file requires a valid config file!"
                        fi
                        ;;
                    -h|-help)
                        help subdomain
                        ;;
                    *)
                        print_error "Unknown option '$1'"
                        ;;
                esac
                shift
            done
            ;;
        screenshot)
            mode="screenshot"
            shift
            while [[ "$1" != "" ]]; do
                case $1 in
                    -c|-config-file)
                        shift
                        if [[ -r "$1" ]]; then
                            config_file="$1"
                        else
                            print_error "-c|-config-file requires a valid config file!"
                        fi
                        ;;
                    -h|-help)
                        help screenshot
                        ;;
                    *)
                        print_error "Unknown option '$1'"
                        ;;
                esac
                shift
            done
            ;;
        deep)
            mode="deep"
            shift
            while [[ "$1" != "" ]]; do
                case $1 in
                    -c|-config-file)
                        shift
                        if [[ -r "$1" ]]; then
                            config_file="$1"
                        else
                            print_error "-c|-config-file requires a valid config file!"
                        fi
                        ;;
                    -h|-help)
                        help deep
                        ;;
                    *)
                        print_error "Unknown option '$1'"
                        ;;
                esac
                shift
            done
            ;;
        leaks)
            mode="leaks"
            shift
            while [[ "$1" != "" ]]; do
                case $1 in
                    -c|-config-file)
                        shift
                        if [[ -r "$1" ]]; then
                            config_file="$1"
                        else
                            print_error "-c|-config-file requires a valid config file!"
                        fi
                        ;;
                    -h|-help)
                        help leaks
                        ;;
                    *)
                        print_error "Unknown option '$1'"
                        ;;
                esac
                shift
            done
            ;;
        gdork)
            mode="gdork"
            shift
            while [[ "$1" != "" ]]; do
                case $1 in
                    -c|-config-file)
                        shift
                        if [[ -r "$1" ]]; then
                            config_file="$1"
                        else
                            print_error "-c|-config-file requires a valid config file!"
                        fi
                        ;;
                    -h|-help)
                        help gdork
                        ;;
                    *)
                        print_error "Unknown option '$1'"
                        ;;
                esac
                shift
            done
            ;;
        test)
            mode="test"
            shift
            while [[ "$1" != "" ]]; do
                case $1 in
                    -c|-config-file)
                        shift
                        if [[ -r "$1" ]]; then
                            config_file="$1"
                        else
                            print_error "-c|-config-file requires a valid config file!"
                        fi
                        ;;
                    -h|-help)
                        help
                        ;;
                    *)
                        print_error "Unknown option '$1'"
                        ;;
                esac
                shift
            done
            ;;
        report)
            mode="report"
            shift
            while [[ "$1" != "" ]]; do
                case $1 in
                    -c|-config-file)
                        shift
                        if [[ -r "$1" ]]; then
                            config_file="$1"
                        else
                            print_error "-c|-config-file requires a valid config file!"
                        fi
                        ;;
                    -r|-report)
                        shift
                        if ! [[ "$1" = -?* ]]; then
                            report=$1
                        else
                            print_error "-r|-report requires an argument!"
                        fi        
                        ;;
                    -s|-sub-report)
                        shift
                        if ! [[ "$1" = -?* ]]; then
                            subreport=$1
                        else
                            print_error "-s|-sub-report requires an argument!"
                        fi        
                        ;;
                    -h|-help)
                        help report
                        ;;
                    *)
                        print_error "Unknown option '$1'"
                        ;;
                esac
                shift
            done
            ;;
        help)
            [[ $2 ]] && print_error "'help' takes no arguments!"
            help
            ;;
        -?*)
            print_error "Please parse a mode first"
            ;;
        *)
            print_error "Unknown mode '$1'"
            ;;
    esac
}


check_dependencies() {

    if [[ ! $(which discord.sh) ]]; then
        print_error "${bold}discord.sh${bold} (https://github.com/fieu/discord.sh) not found"
    fi

    if [[ ! $(which colordiff) ]]; then
        print_error "${bold}colordiff${reset} not found"
    fi    

    if [[ ! $(which xclip) ]]; then
        print_error "${bold}xclip${reset} not found"
    fi    

    if [[ ! $(which crt.sh) ]]; then
        print_error "${bold}crt.sh${reset} not found"
    fi    

    if [[ ! $(which subfinder) ]]; then
        print_error "${bold}subfinder${reset} not found"
    fi    

    if [[ ! $(which github-subdomains) ]]; then
        print_error "${bold}github-subdomains${reset} not found"
    fi    

    if [[ ! $(which gobuster) ]]; then
        print_error "${bold}gobuster${reset} not found"
    fi    

    if [[ ! $(which httprobe) ]]; then
        print_error "${bold}httprobe${reset} not found"
    fi    

    if [[ ! $(which gobuster) ]]; then
        print_error "${bold}gobuster${reset} not found"
    fi    

    if [[ ! $(which subdomainizer) ]]; then
        print_error "${bold}subdomainizer${reset} not found"
    fi    

    if [[ ! $(which goaltdns) ]]; then
        print_error "${bold}goaltdns${reset} not found"
    fi    

    if [[ ! $(which anew) ]]; then
        print_error "${bold}anew${reset} not found"
    fi    

    if [[ ! $(which gowitness) ]]; then
        print_error "${bold}gowitness${reset} not found"
    fi    

    if [[ ! $(which whois) ]]; then
        print_error "${bold}whois${reset} not found"
    fi    

    if [[ ! $(which nslookup) ]]; then
        print_error "${bold}nslookup${reset} not found"
    fi    

    if [[ ! $(which shodan) ]]; then
        print_error "${bold}shodan${reset} not found"

        if [[ ! $(shodan info &> /dev/null) ]]; then
            print_error "Please configure ${bold}shodan${reset} by running 'shodan init <api key>'"
        fi
    fi

    if [[ ! $(which nmap) ]]; then
        print_error "${bold}nmap${reset} not found"
    fi
    
    if [[ ! $(which waybackurls) ]]; then
        print_error "${bold}waybackurls${reset} not found"
    fi
    
    if [[ ! $(which feroxbuster) ]]; then
        print_error "${bold}feroxbuster${reset} not found"
    fi
    
    if [[ ! $(which gitrob) ]]; then
        print_error "${bold}gitrob${reset} not found"
    fi
    
    if [[ ! $(which trufflehog) ]]; then
        print_error "${bold}trufflehog${reset} not found"
    fi
    
    if [[ ! $(which jq) ]]; then
        print_error "${bold}jq${reset} not found"
    fi

    if [[ ! $(which secretfinder) ]]; then
        print_error "${bold}secretfinder${reset} not found"
    fi
    
    if [[ ! $(which dnsreaper) ]]; then
        print_error "${bold}dnsreaper${reset} not found"
    fi
    
    if [[ ! $(which bat) ]]; then
        print_error "${bold}bat${reset} not found"
    fi
    
    if [[ ! $(which nuclei) ]]; then
        print_error "${bold}nuclei${reset} not found"
    fi
    
}

## Run functions based on flags

check_dependencies

flags "$@"

case $mode in
    init) init
        ;;
    config) config
        ;;
    report) reports
        ;;
    recon) func_wrapper recon "Complete Recon"
        ;;
    subdomain) func_wrapper subdomain_recon "Subdomain Recon"
        ;;
    screenshot) func_wrapper subdomain_screenshot "Screenshots of Subdomains"
        ;;
    deep) func_wrapper deep_domain_recon "Deep Domain Recon"
        ;;
    leaks) func_wrapper leaks "Leaks"
        ;;
    gdork) github_dorking_links
        ;;
    test) func_wrapper _test "Test"
        ;;
    *) print_error "Invalid mode \"${mode}\"!"
        ;;
esac