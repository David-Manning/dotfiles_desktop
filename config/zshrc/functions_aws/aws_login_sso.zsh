function aws_login_sso()
{
    if [[ "$1" == "--list" ]]; then
        local profile
        for profile in $(aws configure list-profiles); do
            echo "$profile  $(aws configure get sso_account_id --profile "$profile")  $(aws configure get region --profile "$profile")"
        done
        return
    fi

    if ! aws sts get-caller-identity --profile "$1" >/dev/null 2>&1; then
        aws sso login --profile "$1" || return 1
    fi

    export AWS_PROFILE="$1"
}

_aws_login_sso()
{
    compadd -- --list $(aws configure list-profiles)
}

(( $+functions[compdef] )) && compdef _aws_login_sso aws_login_sso
