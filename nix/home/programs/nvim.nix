# 🖖im
{ home, pkgs, ... }: {
  imports = [ ];

  home.packages = with pkgs; [ python38Packages.pynvim ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    # builtins.readFile ../../../dot/vimrc;
    # in theory by but actually set by setup.sh, and we symink so it's
    # editable.
    plugins = [{
      plugin = pkgs.vimPlugins.nvim-lspconfig;
      type = "lua";
      config = ''
        local function toBase64URL(str)
          local b64 = url.escape(str):gsub('+', '-'):gsub('/', '_'):gsub('=', "")
          return b64
        end
        require 'lspconfig'.grammarly.setup {
            cmd = { "${pkgs.nodePackages_latest.grammarly-languageserver}/bin/grammarly-languageserver", "--stdio" },
            filetypes = { "markdown", "text", "tex" },
            init_options = {
                clientId = 'client_BaDkMgx4X19X9UxxYRCXZo',
            },
        }
        vim.diagnostic.config({
          virtual_text = false
        })
        vim.fn.sign_define('DiagnosticSignError', { text = '', texthl = 'DiagnosticSignError' })
        vim.fn.sign_define('DiagnosticSignWarn', { text = '', texthl = 'DiagnosticSignWarn' })
        vim.fn.sign_define('DiagnosticSignInfo', { text = '', texthl = 'DiagnosticSignInfo' })
        vim.fn.sign_define('DiagnosticSignHint', { text = '', texthl = 'DiagnosticSignHint' })
        -- Show line diagnostics automatically in hover window
        vim.o.updatetime = 250
        vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
        vim.lsp.handlers["workspace/executeCommand"] = vim.lsp.with(
          function(command, args, ctx, config)
            if command ~= "GrammarlyLogin" then
              return
            end
            local externalRedirectUri = "https://vscode-extension-grammarly.netlify.app/.netlify/functions/redirect"
            -- Send the request to the LSP server
            vim.lsp.buf_request(0, "$/getOAuthUrl", {}, function(err, _, oauthUrl)
              if err then
                print("Error:", err)
              else
                -- Process the result, which should be the OAuth URL
                -- Open the URL in an external browser or handle it otherwise
                -- local parsedUrl = url.parse(oauthUrl)
                -- Add the state parameter to the query string
                -- parsedUrl.query = oauthUrl.query or {}
                vim.print(oauthUrl)
                vim.print(oauthUrl .. "&state=" .. toBase64URL(externalRedirectUri))
              end
            end)
            -- Call the LSP server to login (another hypothetical example)
            -- vim.lsp.buf.execute_command({ command = 'grammarly.login' })
          end, {command = 'GrammarlyLogin'})
      '';
    }];
    extraConfig = ''
      source ~/.config/nvim/user.vim
      hi LspDiagnosticsVirtualTextError guifg=red gui=bold,italic,underline
      hi LspDiagnosticsVirtualTextWarning guifg=orange gui=bold,italic,underline
      hi LspDiagnosticsVirtualTextInformation guifg=yellow gui=bold,italic,underline
      hi LspDiagnosticsVirtualTextHint guifg=green gui=bold,italic,underline
    '';
    withNodeJs = true;

    # python is true by default, but we need pybtex for managing citations.
    # see https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/python-packages.nix
    extraPython3Packages = py: with py; [ pybtex ];
  };
}
