{ pkgs, lib, environment, ... }:

{
  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = lib.mkForce false;

  users.users.z = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.zsh;
    home = "/home/z";
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$7moZhPpe9j4CcF$AGIBa8grd/NVNZoUgMJjgELvmRHhNyZUz4X/0ddkFdcBnSAGkqK4ViIXh6YmbS84N45PR4v0NdozTTUX9ztFa0";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDaYzXou6p+ikq3yE9qBmFWbaR0QYPNhIeDA/UXqas17IwDkdf8NJ5r2l395iJKpJKPuVuxiq7WyCJ/AEXJaEFWi3KX8KtTeK3+WMHMUF9VdoMww8wCgirwY4d00vxcUvSTSSEVkQomtXdo85xRJdeKF9VShmkwmzDitq4ATnmE9AH4pYnYVgGUAf/767/kaVChH8NpUexW90vOlE9rh0UGQrpumdmfkpfhN3TNWyUq5WgjBD6pFQ6Y/xfe81XUYBS04INLz3YlzyClJeeZvfGO7r99Nt+jY7axbpPrDXZXiL8b9gj0C5238CBwIbRPvIY3QOJTlx0hO8469yTNIaOd pokaichang72@gmail.com"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQ87/fVrygCUFu+J2OG6jGoHbw0gzo1y7yKshBP9TqQkjm+Jshhg/DTGjbMQN9flHgS+RgN1Eb8YfoF4y5q5C+kq4HJVVGPmoQx2HfU8b6dIXW+JvHHPHeh5/zFf0ji9MYlMgwWXTXIA/x6/8MNSra2XJqO++ZsJhRLqPazjBK7QrWAlqgWkVEHqc6GJBBkLkJEiohpXHSv2ygiDBWDzepfwGqU+NtK9uLR4SdPEX3a0fEmNajX7C9oPpRTgcAxxfg+UjKqK5ojaSnYZSUtheddITsYJ7rbRPrYnPwlTuoLSJcMduMbwCB1Tu1mbi8xf2LQpSB63P0//NSJkSUWu49 pokaichang72+mob@gmail.com"
    ];
  };

  environment.extraInit = lib.mkAfter ''
    if [ "$(whoami)" = "z" ]; then
      if [ ! -d "$HOME/.dotfiles" ]; then
        echo ""
        echo ""
        echo " _______________________________________ "
        echo "/ Welcome!                              \\"
        echo "|                                       |"
        echo "| Since this is your first visit after  |"
        echo "| the system has been setup, we'll need |"
        echo "| some time to get everything in place. |"
        echo "\ It may take a few minutes...          /"
        echo " --------------------------------------- "
        echo "        \                         .      "
        echo "         \                       ==.     "
        echo "                                ===      "
        echo "       _--------------------____/ ===    "
        echo "      |                          /  ===- "
        echo "       \_______ O  ___        __/        "
        echo "         \     \    \:     __/           "
        echo "          \_____\_________/              "
        echo ""
        echo ""
        echo "Preparing dotfiles..."
        echo ""
        git clone "https://github.com/zetavg/dotfiles.git" "$HOME/.dotfiles"
        cd "$HOME/.dotfiles"
        git remote remove origin
        git remote add origin "git@github.com:zetavg/dotfiles.git"
        git branch --set-upstream-to=origin/master master
        ./install
        echo 'if [ ! -z "$ZSH_NAME" ]; then command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"; fi' >> ~/.profile_after_initialized
        echo ""
        echo ""
        echo " _______________________________________ "
        echo "/ It's done!                            \\"
        echo "|                                       |"
        echo "| You can now make your self at home in |"
        echo "\ this brand new system. Enjoy!         /"
        echo " --------------------------------------- "
        echo "        \                         .      "
        echo "         \                       ==.     "
        echo "                                ===      "
        echo "       _--------------------____/ ===    "
        echo "      |                          /  ===- "
        echo "       \_______ ^  ___        __/        "
        echo "         \     \    \:     __/           "
        echo "          \_____\_________/              "
        echo ""
        cd
      fi
    fi

    :
  '';
}
