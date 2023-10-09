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

default_tasks=("subdomain" "screenshot" "services" "deep_domains" "leaks")

my_date() {
    date +%a%e\ %b\ %I:%M:%S\ %Y
}

## Flag Execution

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
                        if [[ "$1" ]]; then
                            target="$1"
                        else
                            print_error "-t|-target requires an argument!"
                        fi
                        shift
                        ;;
                    -ght|-github-token)
                        shift
                        if [[ "$1" ]]; then
                            ghtoken="$1"
                        else
                            print_error "-ght|-github-token requires an argument!"
                        fi
                        shift
                        ;;
                    -ghr|-github-recon)
                        shift
                        if [[ "$1" ]]; then
                            github_recon="$1"
                        else
                            print_error "-ghr|-github-recon requires an argument!"
                        fi
                        shift
                        ;;
                    -glt|-gitlab-token)
                        shift
                        if [[ "$1" ]]; then
                            gltoken="$1"
                        else
                            print_error "-glt|-gitlab-token requires an argument!"
                        fi
                        shift
                        ;;
                    -glr|-gitlab-recon)
                        shift
                        if [[ "$1" ]]; then
                            gitlab_recon="$1"
                        else
                            print_error "-glr|-gitlab-recon requires an argument!"
                        fi
                        shift
                        ;;
                    -b|-brute-wordlists)
                        shift
                        if [[ "$1" ]]; then
                            input_brute_wordlist="$1"
                        else
                            print_error "-b|-brute-wordlist requires a wordlist file!"
                        fi
                        shift
                        ;;
                    -p|-path)
                        shift
                        if [[ "$1" && -d "$1" ]]; then
                            path="$(realpath $1)"
                        else
                            print_error "-p|-path requires a valid path!"
                        fi
                        shift
                        ;;
                    -ct|-custom-tasks)
                        shift
                        if [[ "$1" ]]; then
                            custom_task="$1"
                        else
                            print_error "-ct|-custom-tasks requires an argument!"
                        fi
                        shift
                        ;;
                    -d|-deep-domains)
                        shift
                        if [[ "$1" && -r "$2" ]]; then
                            deep_domains+=("$1")
                            fuzz_wordlist+=("$2")
                        else
                            print_error "-d|-deep-domains requires a domain and a valid path!!"
                        fi
                        shift 2
                        ;;
                    -h|-help)
                        help init
                        ;;
                    -?*)
                        print_error "Unknown option '$1'"
                        ;;
                    *)
                        print_error "Missing options"
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
                        if [[ "$1" ]]; then
                            target="$1"
                        else
                            print_error "-t|-target requires an argument!"
                        fi
                        shift
                        ;;
                    -d|-deep-domains)
                        shift
                        if [[ "$1" && -r "$2" ]]; then
                            deep_domains+=("$1")
                            fuzz_wordlist+=("$2")
                        else
                            print_error "-d|-deep-domains requires a domain and a valid path!"
                        fi
                        shift 2
                        ;;
                    -ght|-github-token)
                        shift
                        if [[ "$1" ]]; then
                            ghtoken="$1"
                        else
                            print_error "-ght|-github-token requires an argument!"
                        fi
                        shift
                        ;;
                    -ghr|-github-recon)
                        shift
                        if [[ "$1" ]]; then
                            github_recon="$1"
                        else
                            print_error "-ghr|-github-recon requires an argument!"
                        fi
                        shift
                        ;;
                    -glt|-gitlab-token)
                        shift
                        if [[ "$1" ]]; then
                            gltoken="$1"
                        else
                            print_error "-glt|-gitlab-token requires an argument!"
                        fi
                        shift
                        ;;
                    -glr|-gitlab-recon)
                        shift
                        if [[ "$1" ]]; then
                            gitlab_recon="$1"
                        else
                            print_error "-glr|-gitlab-recon requires an argument!"
                        fi
                        shift
                        ;;
                    -b|-brute-wordlist)
                        shift
                        if [[ "$1" ]]; then
                            input_brute_wordlist="$1"
                        else
                            print_error "-b|-brute-wordlist requires a wordlist file!"
                        fi
                        shift
                        ;;
                    -a|-attack-method)
                        shift
                        if [[ "$1" ]]; then
                            attack_method="$1"
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
                    -n|-nano)
                        nano_it='true'
                        shift
                        ;;
                    -h|-help)
                        help config
                        ;;
                    -?*)
                        print_error "Unknown option '$1'"
                        ;;
                    *)
                        print_error "Missing options"
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
                        shift
                        ;;
                    -h|-help)
                        help recon
                        ;;
                    -?*)
                        print_error "Unknown option '$1'"
                        ;;
                    *)
                        print_error "Missing options"
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
                        shift
                        ;;
                    -h|-help)
                        help subdomain
                        ;;
                    -?*)
                        print_error "Unknown option '$1'"
                        ;;
                    *)
                        print_error "Missing options"
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
                        shift
                        ;;
                    -h|-help)
                        help scr
                        ;;
                    -?*)
                        print_error "Unknown option '$1'"
                        ;;
                    *)
                        print_error "Missing options"
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
                        shift
                        ;;
                    -h|-help)
                        help deep
                        ;;
                    -?*)
                        print_error "Unknown option '$1'"
                        ;;
                    *)
                        print_error "Missing options"
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
                        shift
                        ;;
                    -h|-help)
                        help leaks
                        ;;
                    -?*)
                        print_error "Unknown option '$1'"
                        ;;
                    *)
                        print_error "Missing options"
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
                        shift
                        ;;
                    -h|-help)
                        help deep
                        ;;
                    -?*)
                        print_error "Unknown option '$1'"
                        ;;
                    *)
                        print_error "Missing options"
                        ;;
                esac
                shift
            done
            ;;
        test)
            mode="test"
            ;;
        help)
            help
            ;;
        *)
            print_error "Unknown option '$1'" no_exit
            echo ""
            help
            ;;
    esac
}
## Functions

print_error() {
    echo -e "${bold}${red}ERROR:${reset} $1"
    [[ "$2" = "no_exit" ]] || exit 1
}

print_message() {
    echo -e "\n  ${green}[+]${reset}${bold} $1${reset} \n"
}

print_end() {
    echo -e "\n\n  ${blue}[+]${reset}${bold} $1${reset} \n"
}

print_warning() {
    echo -e "\n  ${yellow}[+]${reset}${bold} $1${reset} \n"
}

print_sub() {
    echo -e "${blue}=>${reset}${italic} $1${reset}"
}

print_announce() {
    start_date="($(my_date))"
    dashes=$(python -c "print('-' * (len(\"$1 $start_date\") + 30))")
    echo -e "\n  $bold$dashes$reset"
    echo -e "  ${bold}${blue}============>>${reset}${bold} ${1} ${start_date} ${blue}<<============${reset}"
    echo -e "  $bold$dashes$reset\n"
}

my_diff() {
    old=$1
    new=$2
    report=$3

    difference="$([[ -r $old ]] && colordiff $old $new | sed -e "s/</-/g" -e "s/>/+/g" | grep -Ev '\---')"

    if [[ $difference ]]; then
        echo -e "\n  ${orange}[+]${reset}${bold} Found changes in ${report} report${reset} \n"
        echo -e "$difference"
    fi
}

prompt() {
    read -p "   ${red}->${reset} $1 " userinput
    echo ""
}

help() {
    if [[ "$1" = "init" ]]; then
        echo "${green}${bold}Usage:${reset} $0 ${cyan}init${reset} [OPTIONS]"
        echo ""
        echo "${green}${bold}Flags:${reset}"
        echo "  ${magenta}${bold}-t -target${reset} domain                       ${bold}Mandatory:${reset} Target domain"
        echo "  ${magenta}${bold}-b -brute-wordlists${reset} file[,file,...]     ${bold}Mandatory:${reset} Wordlist(s) for subdomain brute-forcing"
        echo "  ${magenta}${bold}-ght -github-token${reset} token                ${bold}Mandatory:${reset} GitHub Token"
        echo "  ${magenta}${bold}-ghr -github-recon${reset} url[,url,...]        GitHub Repos to enumerate"
        echo "  ${magenta}${bold}-glt -gitlab-token${reset} token                GitLab Token"
        echo "  ${magenta}${bold}-glr -gitlab-recon${reset} url[,url,...]        GitLab Repos to enumerate"
        echo "  ${magenta}${bold}-p -path${reset} path                           Path to recon report directory"
        echo "  ${magenta}${bold}-ct -custom-tasks${reset} task[,task,...]       Custom task sequence"
        echo "  ${magenta}${bold}-d -deep-domains${reset} domain wordlist        Domains to fuzz"        
        echo "  ${magenta}${bold}-h -help${reset}                                ${bold}Standalone:${reset} Print this help message"
        echo ""
        echo "${green}${bold}Available Recon Tasks:${reset}"
        for attack in ${default_tasks[*]}; do
            echo "  ${bold}${attack}${reset}"
        done
    elif [[ "$1" = "config" ]]; then
        echo "${green}${bold}Usage:${reset} $0 ${cyan}config${reset} [OPTIONS]"
        echo ""
        echo "${green}${bold}Flags:${reset}"
        echo "  ${magenta}${bold}-c -config-file${reset} file                    ${bold}Mandatory:${reset} Configuration file for target"
        echo "  ${magenta}${bold}-t -target${reset} domain                       Change target domain"
        echo "  ${magenta}${bold}-b -brute-wordlists${reset} file[,file,...]     Add wordlist(s) for subdomain brute-forcing"
        echo "  ${magenta}${bold}-ght -github-token${reset} token                Change GitHub Token"
        echo "  ${magenta}${bold}-ghr -github-recon${reset} url[,url,...]        Add GitHub Repos to enumerate"
        echo "  ${magenta}${bold}-glt -gitlab-token${reset} token                Change GitLab Token"
        echo "  ${magenta}${bold}-glr -gitlab-recon${reset} url[,url,...]        Add GitLab Repos to enumerate"
        echo "  ${magenta}${bold}-a -attack-method${reset} task[,task,...]       Change task sequence"
        echo "  ${magenta}${bold}-d -deep-domains${reset} domain wordlist        Add domains to deep searchs"        
        echo "  ${magenta}${bold}-n -nano${reset}                                ${bold}Standalone:${reset} Edit the config file using nano"
        echo "  ${magenta}${bold}-h -help${reset}                                ${bold}Standalone:${reset} Print this help message"
        echo ""
        echo "${green}${bold}Available Recon Tasks:${reset}"
        for attack in ${default_tasks[*]}; do
            echo "  ${bold}${attack}${reset}"
        done
    elif [[ $1 =~ subdomain|screenshot|fingerprint|deep|leaks|gdork|recon ]]; then
        echo "${green}${bold}Usage:${reset} $0 ${cyan}recon${reset}|${cyan}subdomain${reset}|${cyan}screenshot${reset}|${cyan}fingerprint${reset}|${cyan}deep${reset}|${cyan}leaks${reset}|${cyan}gdork${reset} [OPTIONS]"
        echo ""
        echo "${green}${bold}Flags:${reset}"
        echo "  ${magenta}${bold}-c -config-file${reset} file                    ${bold}Mandatory:${reset} Configuration file for target"
        echo ""
    else
        echo "${green}${bold}Usage:${reset} $0 MODE [OPTIONS]"
        echo ""
        echo "${green}${bold}Main Modes:${reset}"
        echo "    ${cyan}help   ${yellow}=>${reset} Print this help message"
        echo "    ${cyan}init   ${yellow}=>${reset} Initiate configuration for recon on target"
        echo "    ${cyan}config ${yellow}=>${reset} Modify configuration of specific target"        
        echo "    ${cyan}recon  ${yellow}=>${reset} Run recon based on configuration file"
        echo ""
        echo "${green}${bold}Single Functions:${reset}"    
        echo "    ${cyan}subdomain   ${yellow}=>${reset} Subdomain Recon"
        echo "    ${cyan}screenshot  ${yellow}=>${reset} Screenshots of Subdomains"
        echo "    ${cyan}fingerprint ${yellow}=>${reset} Fingerprint/Service Scan"
        echo "    ${cyan}deep        ${yellow}=>${reset} Deep Domain Recon"
        echo "    ${cyan}leaks       ${yellow}=>${reset} Scan GiHub/GitLab (and other sites) repos for leaks"
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
    print_message "GitHub Dorking Links Copied  -->  ./$(realpath --relative-to="." "${recon_dir}/github_dorking.txt")"
}

subdomain_recon() {

    print_announce "SUBDOMAIN ENUMERATION"
    start_seconds=$SECONDS

    ## crt.sh

    print_message "Pulling down 'crt.sh' domains  -->  ./$(realpath --relative-to="." "$subdomain_dir/crt_sh.txt")"
    [[ -f $subdomain_dir/crt_sh.txt ]] && mv $subdomain_dir/crt_sh.txt $subdomain_dir/crt_sh.old
    [[ -f $subdomain_dir/crt_sh_wildcard.txt ]] && mv $subdomain_dir/crt_sh_wildcard.txt $subdomain_dir/crt_sh_wildcard.old

    crt.sh -t "$target" > $subdomain_dir/crt_temp.txt
    cat $subdomain_dir/crt_temp.txt | grep -v '*' | probe | tee $subdomain_dir/crt_sh.txt

    print_message "crt.sh wildcard domains"
    grep '*' $subdomain_dir/crt_temp.txt | tee $subdomain_dir/crt_sh_wildcard.txt

    rm $subdomain_dir/crt_temp.txt

    my_diff $subdomain_dir/crt_sh.old $subdomain_dir/crt_sh.txt "crt.sh"
    my_diff $subdomain_dir/crt_sh_wildcard.old $subdomain_dir/crt_sh_wildcard.txt "crt.sh wildcard domains"

    ## Subfinder

    print_message "Running 'subfinder'  -->  ./$(realpath --relative-to="." "$subdomain_dir/subfinder.txt")"
    [[ -f $subdomain_dir/subfinder.old ]] && mv $subdomain_dir/subfinder.old $subdomain_dir/subfinder.txt

    subfinder -d "$target" -silent | sort -u | probe | tee $subdomain_dir/subfinder.txt

    my_diff $subdomain_dir/subfinder.old $subdomain_dir/subfinder.txt "subfinder"

    ## GitHub Subdomains

    print_message "Running 'github-subdomains.py'  -->  ./$(realpath --relative-to="." "$subdomain_dir/github_subdomains.txt")"
    [[ -f $subdomain_dir/github_subdomains.txt ]] && mv $subdomain_dir/github_subdomains.txt $subdomain_dir/github_subdomains.old

    github-subdomains -t $ghtoken -d $target | grep -v "error occurred:" | tee $subdomain_dir/github_subdomain_unsorted.txt
    sleep 6
    github-subdomains -t $ghtoken -d $target | grep -v "error occurred:" | tee -a $subdomain_dir/github_subdomain_unsorted.txt
    sleep 6
    github-subdomains -t $ghtoken -d $target | grep -v "error occurred:" | tee -a $subdomain_dir/github_subdomain_unsorted.txt
    sleep 10
    github-subdomains -t $ghtoken -d $target | grep -v "error occurred:" | tee -a $subdomain_dir/github_subdomain_unsorted.txt

    sort -u $subdomain_dir/github_subdomain_unsorted.txt | probe > $subdomain_dir/github_subdomains.txt
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

    print_message "Running 'gobuster' (brute-force)  -->  ./$(realpath --relative-to="." "$subdomain_dir/gobuster.txt")"
    [[ -f $subdomain_dir/gobuster.txt ]] && mv $subdomain_dir/gobuster.txt $subdomain_dir/gobuster.old

    gobuster dns -d $target -w $brute_wordlist -zq --no-error --no-color | cut -d ' ' -f 2 | probe | tee $subdomain_dir/gobuster.txt

    
    my_diff $subdomain_dir/gobuster.old $subdomain_dir/gobuster.txt "gobuster"

    ## Combining Files

    sort -u $subdomain_dir/crt_sh.txt $subdomain_dir/subfinder.txt $subdomain_dir/github_subdomains.txt $subdomain_dir/gobuster.txt | extract_url > $subdomain_dir/combined_temp.txt

    ## Subdomainizer

    print_message "Running 'subdomainizer'  -->  ./$(realpath --relative-to="." "$subdomain_dir/subdomainizer.txt")"
    [[ -f $subdomain_dir/subdomainizer.txt ]] && mv $subdomain_dir/subdomainizer.txt $subdomain_dir/subdomainizer.old
    [[ -f $subdomain_dir/subdomainizer_info.txt ]] && mv $subdomain_dir/subdomainizer_info.txt $subdomain_dir/subdomainizer_info.old

    subdomainizer -l combined_temp.txt -gt $ghtoken -g -o subdomainizer.txt
    grep "Found some secrets(might be false positive)..." -A 1000 subdomainizer.txt | sed '/___End\ of\ Results__/d' > $leaks_dir/subdomainizer_info.txt

    my_diff $subdomain_dir/subdomainizer.old $subdomain_dir/subdomainizer.txt "subdomainizer"
    my_diff $subdomain_dir/subdomainizer_info.old $subdomain_dir/subdomainizer_info.txt "subdomainizer leaks"
    
    ## Combining Files

    sort -u $subdomain_dir/combined_temp.txt $subdomain_dir/subdomainizer.txt > $subdomain_dir/combined_subdomains.txt
    cat $subdomain_dir/combined_subdomains.txt | extract_url > $subdomain_dir/combined_subdomains_stripped.txt

    rm $subdomain_dir/combined_temp.txt

    ## Subfinder recusive

    print_message "Running 'subfinder recursive'  -->  ./$(realpath --relative-to="." "$subdomain_dir/subfinder_recursive.txt")"
    [[ -f $subdomain_dir/subfinder_recursive.txt ]] && mv $subdomain_dir/subfinder_recursive.txt $subdomain_dir/subfinder_recursive.old

    subfinder -recursive -list combined_subdomains_stripped.txt -silent | sort -u | probe | tee $subdomain_dir/subfinder_recursive.txt

    my_diff $subdomain_dir/subfinder_recursive.old $subdomain_dir/subfinder_recursive.txt "subfinder recursive"


    ## Combining Files

    sort -u *_recursive.txt > combined_recursive.txt
    cat combined_recursive.txt | extract_url > combined_recursive_stripped.txt

    ## GoAltDNS

    print_message "Running 'goaltdns'  -->  ./$(realpath --relative-to="." "$subdomain_dir/goaltdns.txt")"
    [[ -f $subdomain_dir/goaltdns.txt ]] && mv $subdomain_dir/goaltdns.txt $subdomain_dir/goaltdns.old
    
    goaltdns -l combined_recursive_stripped.txt -w $brute_wordlist | sort -u | probe | tee $subdomain_dir/goaltdns.txt

    my_diff $subdomain_dir/goaltdns.old $subdomain_dir/goaltdns.txt "goaltdns"

    ## Final Combanation

    sort -u goaltdns.txt combined_recursive.txt > final_subdomains.txt
    cat final_subdomains | extract_url > final_subdomains_stripped.txt

    ## New Subdomains

    if [[ -f $subdomain_dir/final_subdomains.old ]]; then
        cat $subdomain_dir/final_subdomains.txt | anew $subdomain_dir/final_subdomains.old -d > $subdomain_dir/new_subdomains.txt
    else
        cat $subdomain_dir/final_subdomains.txt > $subdomain_dir/new_subdomains.txt
    fi

    print_message "Discoverd $(wc -l $subdomain_dir/new_subdomains.txt) NEW Subdomains  -->  ./$(realpath --relative-to="." "$subdomain_dir/new_subdomains.txt")"
    
    cat $subdomain_dir/new_subdomains.txt

    ## Time Taken

    end_seconds=$SECONDS
    execution_seconds=$((end_seconds - start_seconds))
    execution_time=$(date -u -d @${execution_seconds} +"%T")
    print_end "Completed Subdomain Recon (Took $execution_time)  -->  ./$(realpath --relative-to="." "$subdomain_dir/final_subdomains.txt")"
}

subdomain_screenshot() {

    print_announce "TAKING SCREENSHOTS OF SUBDOMAINS"
    start_seconds=$SECONDS

    ## Take The Screenshots

    if [[ -f $subdomain_dir/new_subdomains.txt && $(cat $subdomain_dir/new_subdomains.txt) ]]; then
        gowitness file -f $subdomain_dir/final_subdomains.txt --delay 1 -P $screenshot_dir
    else
        print_warning "No New Subdomains Found"
    fi

    ## Time Taken

    end_seconds=$SECONDS
    execution_seconds=$((end_seconds - start_seconds))
    execution_time=$(date -u -d @${execution_seconds} +"%T")
    print_end "Completed Screenshots of Subdomains (Took $execution_time)  -->  ./$(realpath --relative-to="." "$recon_dir/screenshots")"
}

services_recon() {

    print_announce "FINGERPRINT/SERVICE SCANNING"
    start_seconds=$SECONDS

    if [[ -f $subdomain_dir/new_subdomains.txt && $(cat $subdomain_dir/new_subdomains.txt) ]]; then
 
        ## WOHIS REPORT

        domains=($(awk -F "." '{print $(NF-1)"."$NF}' $subdomain_dir/new_subdomains.txt | sort -u))

        for url in "${domains[@]}"; do
            echo "==============>> $url WHOIS report <<=============="
            whois $url
            echo "\n\n\n"    
        done | tee -a $fingerprint_dir/whois_report.txt

        ## Extract IPs of URLs

        print_message "Extracting IP Addresses of Discovered Subdomains  -->  ./$(realpath --relative-to="." "$fingerprint_dir/IPs.txt")"

        new_subdomains=($(cat $subdomain_dir/new_subdomains.txt))

        for url in "${new_subdomains[@]}"; do
            nslookup $url | grep "Address: " | head -1 | sed -e "s/Address:\ //"
        done | tee $fingerprint_dir/IPs.txt

        ## SHODAN

        print_message "Generating Shodan Report  -->  ./$(realpath --relative-to="." "$fingerprint_dir/shodan_report.txt")"

        ips=($(cat $fingerprint_dir/IPs.txt))

        for ip in "${ips[@]}"; do
            echo -e "==============>> $ip report <<=============="
            shodan host $ip
            echo -e "\n\n" 
        done | tee -a $fingerprint_dir/shodan_report.txt

        ## NMAP

        print_message "Running Nmap Scans  -->  ./$(realpath --relative-to="." "$fingerprint_dir/nmap_scans.txt")"

        nmap -p 0-10000 -sV -iL $fingerprint_dir/IPs.txt -oG nmap_scans_temp.txt

        sed '/#\ Nmap/d' nmap_scans_temp.txt | grep -v "Status: " >> nmap_scans.txt
        rm nmap_scans_temp.txt

        ## Time Taken

        end_seconds=$SECONDS
        execution_seconds=$((end_seconds - start_seconds))
        execution_time=$(date -u -d @${execution_seconds} +"%T")
        print_end "Completed Fingerprint/Service Scan of Subdomains (Took $execution_time)  -->  ./$(realpath --relative-to="." "$recon_dir/screenshots")"        
    else
        print_warning "No New Subdomains Found"
    fi
}

deep_domain_recon() {

    print_announce "DEEP DOMAIN RECON"
    start_seconds=$SECONDS
    
    if [[ "${deep_domains[*]}" ]]; then
        start_seconds=$SECONDS
        
        for i in "${!deep_domains[@]}"; do

            domain="${deep_domains[$i]}"
            wordlist="${fuzz_wordlist[$i]}"
            [[ -d $deep_dir/$domain ]] || mkdir $deep_dir/$domain
            
            ## Wayback urls

            print_message "Running 'waybackurls' on '$domain'  -->  ./$(realpath --relative-to="." "$deep_dir/$domain/waybackurls.txt")"
            [[ -f $deep_dir/$domain/waybackurls.txt ]] && mv $deep_dir/$domain/waybackurls.txt $deep_dir/$domain/waybackurls.old
        
            waybackurls $domain | tee $deep_dir/$domain/waybackurls.txt

            my_diff $deep_dir/$domain/waybackurls.old $deep_dir/$domain/waybackurls.txt "waybackurls"

            ## Feroxbuster dir brute-forcing

            print_message "Running 'feroxbuster' on '$domain'  -->  ./$(realpath --relative-to="." "$deep_dir/$domain/feroxbuster.txt")"
            [[ -f $deep_dir/$domain/feroxbuster.txt ]] && mv $deep_dir/$domain/feroxbuster.txt $deep_dir/$domain/feroxbuster.old
        
            feroxbuster -u $domain -t 20 -L 20 -w ${fuzz_wordlist[$i]} -o $deep_dir/$domain/feroxbuster.txt
            echo ""

            my_diff $deep_dir/$domain/feroxbuster.old $deep_dir/$domain/feroxbuster.txt "feroxbuster"

        done

        ## Time Taken

        end_seconds=$SECONDS
        execution_seconds=$((end_seconds - start_seconds))
        execution_time=$(date -u -d @${execution_seconds} +"%T")
        print_end "Completed Deep Recon of Domains (Took $execution_time)  -->  ./$(realpath --relative-to="." "$deep_dir")"
    else
        print_warning "No Deep Domains Defined"
    fi
    
}

leaks() {

    print_announce "SCANNING FOR LEAKS"
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
                    print_message "Running 'gitrob' on $platform user '$user'  -->  ./$(realpath --relative-to=. $g_leak_path/)/gitrob_${user}.json"
                    [[ -r ${g_leak_path}/gitrob_${user}.json ]] && mv ${g_leak_path}/gitrob_${user}.json ${g_leak_path}/gitrob_${user}.json.old

                    cd $(dirname $(realpath $(which gitrob)))
                    
                    if [[ $platform = "GitHub" ]]; then
                        gitrob -save ${g_leak_path}/gitrob_${user}.json -mode 2 -exit-on-finish -github-access-token $token $user
                    else
                        gitrob -save ${g_leak_path}/gitrob_${user}.json -mode 2 -exit-on-finish -gitlab-access-token $token $user
                    fi
                    
                    my_diff ${g_leak_path}/gitrob_${user}.json.old ${g_leak_path}/gitrob_${user}.json "gitrob ($user)"
                    
                    cd - &> /dev/null

                    findings=$([[ -r ${g_leak_path}/gitrob_${user}.json ]] && jq .Findings ${g_leak_path}/gitrob_${user}.json)

                    if [[ ! $findings || $findings = "null" ]]; then
                        print_warning "No findings from 'gitrob'"
                    else
                        print_message "'gitrob' findings on $platform user '$user'  -->  ./$(realpath --relative-to=. ${g_leak_path}/)/gitrob_${user}_findings.json"
                        [[ -r ${g_leak_path}/gitrob_${user}_findings.json ]] && mv ${g_leak_path}/gitrob_${user}_findings.json ${g_leak_path}/gitrob_${user}_findings.json.old
                        echo $findings | jq . | tee ${g_leak_path}/gitrob_${user}_findings.json
                        my_diff ${g_leak_path}/gitrob_${user}_findings.json.old ${g_leak_path}/gitrob_${user}_findings.json "gitrob ($user)"
                    fi
                done

                ## Trufflehog

                for repo in "${recon_array[@]}"; do
                    filename="$(echo trufflehog_$(echo $repo | awk -F "/" '{print $(NF-1)"_"$NF}')).json"

                    print_message "Running 'trufflehog' on $platform repo '$repo'  -->  ./$(realpath --relative-to=. $g_leak_path/)/$filename"
                    [[ -r $g_leak_path/$filename ]] && mv $g_leak_path/$filename $g_leak_path/${filename}.old

                    if [[ $platform = "GitHub" ]]; then
                        trufflehog_report=$(trufflehog github --token=$token --repo=$repo -j | jq .)
                    else

                        trufflehog_report=$(trufflehog gitlab --token=$token --repo=$repo -j | jq .)
                    fi

                    if [[ ! $trufflehog_report || $trufflehog_report = "null" ]]; then
                        print_warning "No report from trufflehog"
                    else
                        echo $trufflehog_report | jq . | tee $g_leak_path/$filename
                        my_diff ${g_leak_path}/${filename}.old ${g_leak_path}/$filename "trufflehog ($repo)"
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
    print_end "Completed Scan for Leaks (Took $execution_time)  -->  ./$(realpath --relative-to="." "$leaks_dir")"  
}

init() {

    ## Check For Requirements
    
    if [[ ! "$target" ]]; then
        print_error "Missing target (-t|-target)"
    elif [[ ! "$ghtoken" ]]; then
        print_error "Missing GitHub Token (-ght|-github-token)"
    elif [[ ! "$input_brute_wordlist" ]]; then
        print_error "Missing wordlist for subdomain brute forcing (-b|-brute-wordlist)"
    fi

    if [[ ! "$path" ]]; then
        path=$(realpath .)
    fi

    org=$(echo $target | cut -d '.' -f 1)

    ## Brute Wordlist

    while read -r wordlist; do
        [[ -r $wordlist ]] || print_error "Can't read file '$wordlist'"
    done < <(echo $input_brute_wordlist | sed -e "s/\"//g" -e "s/,/\n/g")

    brute_wordlist=$(echo $input_brute_wordlist | sed 's/,/",\ "/g')

    ## Custom Attacks

    if [[ $custom_task ]]; then
        while read -r attack; do
            match=0
            for dtasks in ${default_tasks[*]}; do
                [[ $dtasks = "$attack" ]] && match=1
            done
            [[ $match = 1 ]] || print_error "Unknowon attack '$attack'"
        done < <(echo $custom_task | sed "s/,/\n/g")
        attack_method_json=$(echo \"$custom_task\" | sed "s/,/\",\ \"/g")
    else
        attack_method_json=$(echo \"${default_tasks[*]}\" | sed "s/\ /\",\ \"/g")
    fi

    ## GitHub Recon

    if [[ $github_recon ]]; then
        github_recon_json=$(echo \"$github_recon\" | sed "s/,/\",\ \"/g")
    fi
    
    ## GitLab Recon

    if [[ $gitlab_recon ]]; then
        gitlab_recon_json=$(echo \"$gitlab_recon\" | sed "s/,/\",\ \"/g")
    fi

    ## Deep Domains

    if [[ ${deep_domains[*]} && ${fuzz_wordlist[*]} ]]; then

        print_message "${fuzz_wordlist[@]}"

        deep_domains_json="$(echo "$(for i in "${!deep_domains[@]}"; do
                                 echo -n "{\"domain\": \"${deep_domains[$i]}\",\"wordlist\": \"${fuzz_wordlist[$i]}\"}"
                             done)" | sed "s/}{/},{/g")"
        print_message "$deep_domains_json"
    fi

    ## Create Directories

    [[ -d "$path/${org}_recon" ]] || mkdir "$path/${org}_recon"
    [[ -d "$path/${org}_recon/subdomains" ]] || mkdir "$path/${org}_recon/subdomains"
    [[ -d "$path/${org}_recon/logs" ]] || mkdir "$path/${org}_recon/logs"
    [[ -d "$path/${org}_recon/leaks" ]] || mkdir "$path/${org}_recon/leaks"
    [[ -d "$path/${org}_recon/leaks/github/" ]] || mkdir "$path/${org}_recon/leaks/github"
    [[ -d "$path/${org}_recon/leaks/gitlab/" ]] || mkdir "$path/${org}_recon/leaks/gitlab"
    [[ -d "$path/${org}_recon/deep_domains" ]] || mkdir "$path/${org}_recon/deep_domains"
    [[ -d "$path/${org}_recon/fingerprint" ]] || mkdir "$path/${org}_recon/fingerprint"

    print_message "$path/${org}_recon/fingerprint"

    recon_dir="$path/${org}_recon"
    subdomain_dir="${recon_dir}/subdomains"
    logs_dir="${recon_dir}/logs"
    leaks_dir="${recon_dir}/leaks"
    github_leaks_dir="${recon_dir}/leaks/gitlab"
    gitlab_leaks_dir="${recon_dir}/leaks/github"
    deep_dir="${recon_dir}/deep_domains"
    fingerprint_dir="${recon_dir}/fingerprint"
    config_file="${recon_dir}/${org}_config.json"

    print_message "$path"

    ## Create JSON File
    
    jq -n "{
            config: {
                    target: \"$target\", 
                    recon_path: \"$recon_dir\", 
                    subdomain_brute_wordlist: [ 
                        \"$brute_wordlist\" 
                    ], 
                    deep_domains: [ 
                        $deep_domains_json
                    ], 
                    git: { 
                        token: { 
                            github: \"$ghtoken\",
                            gitlab: \"$gltoken\" 
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
                    ]
                }
            }" > ${config_file}.new


    if [[ -f $config_file ]]; then
        if [[ $(diff "$config_file" "${config_file}.new") = "" ]]; then 
            print_sub "An ${bold}identical${reset}${italic} configuration file exists (${underline}${config_file}${reset}${italic}), overwrite?"
        else 
            print_sub "A configuration file exists (${underline}${config_file}${reset}${italic}), overwrite?"
        fi

        prompt "[Y/N]:"

        case $userinput in
            y|Y)
                print_sub "Overwriting..."
                mv "${config_file}.new" "${config_file}"
                ;;
            *)
                print_sub "Not overwriting..."
                ;;
        esac
    else
        mv "${config_file}.new" "${config_file}"
    fi

    print_message "JSON Configuration"

    jq . $config_file
}

config() {

    ## Check For Config File

    if [[ ! $config_file ]]; then
        print_error "Please provide a config file (-c|-config-file)"
    fi

    ## Make sure nano is standalone

    if [[ $target || $ghtoken || $deep_domains || $fuzz_wordlist || $input_brute_wordlist || $github_recon || $attack_method ]] && [[ $nano_it ]]; then
        print_error "-n|-nano is a standalone flag"
    fi

    ## Create a Temp Config File

    cp $config_file /tmp/temp_$(basename ${config_file})
    tmp_config_file=/tmp/temp_$(basename ${config_file})

    ## Nano It

    if [[ $nano_it ]]; then
        nano $tmp_config_file
    fi

    ## Change Target

    if [[ $target ]]; then
        jq ".config.target = \"$target\"" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi

    ## Change GitHub Token

    if [[ $ghtoken ]]; then
        jq ".config.git.token.github = \"$ghtoken\"" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi

    ## Change GitHub Token

    if [[ $gltoken ]]; then
        jq ".config.git.token.gitlab = \"$gltoken\"" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi

    ## Add Fuzz Domains

    if [[ "${deep_domains[*]}" && "${fuzz_wordlist[*]}" ]]; then

        print_message "${deep_domains[*]}\n${fuzz_wordlist[*]}"

        for i in "${!deep_domains[@]}"; do
            jq ".config.deep_domains += [{
                                            domain: \"${deep_domains[$i]}\",
                                            wordlist: \"${fuzz_wordlist[$i]}\" 
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

    if [[ $github_recon ]]; then
        
        github_recon_json=$(echo \"$github_recon\" | sed "s/,/\",\ \"/g")

        jq ".config.git.github_recon += [ $github_recon_json ]" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi
    
    ## Add GitLab Repo For Recon

    if [[ $gitlab_recon ]]; then

        gitlab_recon_json=$(echo \"$gitlab_recon\" | sed "s/,/\",\ \"/g")

        jq ".config.git.gitlab_recon += [ $gitlab_recon_json ]" "${tmp_config_file}" > "${tmp_config_file}.tmp"
        mv "${tmp_config_file}.tmp" "${tmp_config_file}"
    fi

    ## Change Attack Method

    if [[ $attack_method ]]; then

        if [[ $attack_method = 'default' ]]; then
            attack_method_json=$(echo \"${default_tasks[*]}\" | sed "s/\ /\",\ \"/g")
        else
            while read -r attack; do
                    match=0
                for dtasks in ${default_tasks[*]}; do
                    [[ $dtasks = "$attack" ]] && match=1
                done
                [[ $match = 1 ]] || print_error "Unknowon attack '$attack'"
            done < <(echo $attack_method | sed "s/,/\n/g")
            attack_method_json=$(echo \"$attack_method\" | sed "s/,/\",\ \"/g")
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
    for attack in ${attack_method[*]}; do
        if [[ $attack = "subdomain" ]]; then
            subdomain_recon
        elif [[ $attack = "screenshot" ]]; then
            subdomain_screenshot
        elif [[ $attack = "services" ]]; then
            services_recon
        elif [[ $attack = "deep_domains" ]]; then
            deep_domain_recon
        elif [[ $attack = "leaks" ]]; then
            leaks
        fi
    done
}

init_vars() {
    [[ $config_file ]] || print_error "Missing config file (-c|-config-file)"

    target=$(jq -r '.config.target' $config_file)
    brute_wordlists=($(jq -r '.config.subdomain_brute_wordlist[]' $config_file))
    ghtoken=$(jq -r '.config.git.token.github' $config_file)
    gltoken=$(jq -r '.config.git.token.gitlab' $config_file)
    github_recon=($(jq -r '.config.git.github_recon[]' $config_file))
    gitlab_recon=($(jq -r '.config.git.gitlab_recon[]' $config_file))
    deep_domains=($(jq -r '.config.deep_domains[].domain' $config_file))
    fuzz_wordlist=($(jq -r '.config.deep_domains[].wordlist' $config_file))
    attack_method=($(jq -r '.config.attack_method[]' $config_file))
    recon_dir=$(jq -r '.config.recon_path' $config_file)

    script_home=$(dirname $(realpath $0))
    org=$(echo $target | cut -d '.' -f 1)

    subdomain_dir="${recon_dir}/subdomains"
    screenshot_dir="{recon_dir}/screenshots"
    logs_dir="${recon_dir}/logs"
    leaks_dir="${recon_dir}/leaks"
    github_leaks_dir="${recon_dir}/leaks/github"
    gitlab_leaks_dir="${recon_dir}/leaks/gitlab"
    fingerprint_dir="${recon_dir}/fingerprint"
    deep_dir="${recon_dir}/deep_domains"

    if ! [[ -d $subdomain_dir || $screenshot_dir || $deep_dir || -d $logs_dir || -d $leaks_dir || -d $fingerprint_dir || -d $github_leaks_dir || -d $gitlab_leaks_dir ]]; then
        print_error "Please run 'init' function"
    fi
}

_test() {
    print_announce "TEST RUN"   
    start_seconds=$SECONDS
    # echo $subdomain_dir
    sleep 10
    end_seconds=$SECONDS
    execution_seconds=$((end_seconds - start_seconds))
    execution_time=$(date -u -d @${execution_seconds} +"%T")
    print_end "Test completed in $execution_time  -->  ./tmp/example.txt"
}

flags "$@"

case $mode in
    init)
        init
        ;;
    config)
        config
        ;;
    recon)
        init_vars
        recon |& tee "$logs_dir/Complete Recon ($(my_date)).log"
        ;;
    subdomain)
        init_vars
        subdomain_recon |& tee "$logs_dir/Subdomain Recon ($(my_date)).log"
        ;;
    screenshot)
        init_vars
        screenshot |& tee "$logs_dir/Screenshots Recon ($(my_date)).log"
        ;;
    deep)
        init_vars
        deep_domain_recon |& tee "$logs_dir/Deep Domain Recon ($(my_date)).log"
        ;;
    leaks)
        init_vars
        leaks |& tee "$logs_dir/Leaks Scan ($(my_date)).log"
        ;;
    gdork)
        init_vars
        github_dorking_links
        ;;
    test)
        _test
        ;;
    *)
        print_error "Invalid mode \"${mode}\"!"
        ;;
esac