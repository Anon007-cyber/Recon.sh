#!/bin/bash

domain=$1
wordlist="/home/aninda_root/recon_tool/SecLists/Discovery/DNS/all.txt"
resolver="/home/aninda_root/recon_tool/resolver/resolver.txt"

domain_enum(){

mkdir -p $domain $domain/sources $domain/Recon

subfinder -d $domain -o $domain/sources/subfinder.txt
assetfinder -subs-only $domain | tee $domain/sources/hackerone.com
amass enum -passive -d $domain -o $domain/sources/passive.txt
shuffledns -d $domain -w $wordlist -r $resolver -o $domain/sources/shuffledns.txt

cat $domain/sources/*.txt > $domain/sources/all.txt

} 
domain_enum


resolving_domain(){
shuffledns -d $domain -list $domain/sources/all.txt -o $domain/domains.txt -r $resolver
}
resolving_domain

http_prob(){
	cat $domain/domains.txt | httpx -threads 200 -o $domain/Recon/httpx.txt

}

http_prob

scanner(){
	cat $domain/Recon/httpx.txt | nuclei -t /root/nuclei-templates/cves/ -c 50 -o $domain/Recon/nuclei/cves.txt
	cat $domain/Recon/httpx.txt | nuclei -t /root/nuclei-templates/technologies -c 50 -o $domain/Recon/nuclei/vulnerabilities.txt
	cat $domain/Recon/httpx.txt | nuclei -t /root/nuclei-templates/files/ -c 50 -o $domain/Recon/nuclei/files.txt


}
scanner
