# detect platform

platform='unknown'
platform_name=$(uname)
if [[ $platform_name == 'Linux' ]]; then
    platform='linux'
elif [[ $platform_name == 'FreeBSD' ]]; then
    platform='freebsd'
elif [[ $platform_name == 'Darwin' ]]; then
    platform='darwin'
fi
echo current platform: ${platform_name}
