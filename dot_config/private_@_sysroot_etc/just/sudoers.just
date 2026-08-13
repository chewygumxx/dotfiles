#!/usr/bin/env just --justfile
# vim: expandtab:shiftwidth=4

#
#
# ~/.config/@_sysroot_etc/justfile
#
#

default:
    @just --list

sudo := require("sudo")

sudoers_dest := / "etc" / "sudoers.d"
sudoers_src  := invocation_directory() / "src" / "sudoers.d"
bkp_dir      := invocation_directory() / "backup"
bkp_suf      := ".bkp."

@fn_ordered file:
    echo {{ if filename(file) =~ '^[^\d]{2}[^-]' {
        error("Filename of '" + filename(file) +
            "' must be prepended with 2 digits and a hyphen ie. 99-name")
     } }}

@fn_dot file:
    echo {{ if filename(file) =~  '\.' {
        error( "Filename of '" + filename(file) + "' must not contain any periods (.)" )
    } }}

@visudo_check:
    echo {{ if "$(cat '{{sudoers_src /}}*' | visudo --check --strict --file=-)" =~ ':[\d]{2}:[\d]{2}:' {
        error("visudo --check returned: $(cat '{{sudoers_src /}}*' | visudo --check --strict --file=-)"
    } }}

backup file:
    sudo cp --update "{{ sudoers_dest / file_name(file) }}" \
        "{{bkp_dir /}}$(cksum --algorithm=md5 '{{sudoers_dest / filen_ame(file)}}')_{{filename(file) + bkp_suf}}"

backup file:
    @mkdir -p "{{ bkp_dir }}"
    cp --update "{{ sudoers_dest / file_name(file) }}" \
        "{{bkp_dir}}/$(cksum --algorithm=md5 '{{sudoers_dest / file_name(file) + bkp_suf +trim_start_match(file, src_dir)}}')"

update file:  (fn_dot file) (fn_ordered file) (visudo_check) (backup file)
    echo "Updating" "{{BLUE + file}}"
    @sudo mkdir -p "{{sudoers_dest}}"
    sudo install --mode=440 -t "{{sudoers_dest}}" "{{sudoers_src / file_name(file)}}"
    sudo cp --update "{{file}}" "{{dest_dir / trim_start_match(file, src_dir)}}" 

apply file:


