{...}: {
  programs.claude-code = {
    enable = true;
    settings = {
      permissions = {
        enable_extension_marketplace = false;
      };
      env = {
        DISABLE_INSTALLATION_CHECKS = "1";
      };
      statusLine = {
        type = "command";
        command = ''
          jq -r '"+\(.cost.total_lines_added // 0) -\(.cost.total_lines_removed // 0) · esc to interrupt | 💰 $\(.cost.total_cost_usd // 0 | . * 100 | floor / 100) | \(((.context_window.current_usage.input_tokens // 0) + (.context_window.current_usage.cache_creation_input_tokens // 0) + (.context_window.current_usage.cache_read_input_tokens // 0)) / 1000 | floor)k/\((.context_window.context_window_size // 200000) / 1000)k (\(.context_window.used_percentage // 0 | floor)%)\(if .rate_limits.five_hour then " | 5h: \(.rate_limits.five_hour.used_percentage | floor)%" else "" end)\(if .rate_limits.seven_day then " 7d: \(.rate_limits.seven_day.used_percentage | floor)%" else "" end)"'
        '';
      };
    };
  };
}
