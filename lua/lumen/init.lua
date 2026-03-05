local api = vim.api

local defaults = {
  floating_window = {
    fullscreen = false,
    scaling_factor = 0.9,
    winblend = 0,
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
  },
}

local options = vim.deepcopy(defaults)
local prev_win = -1
local win = -1
local lumen_found = nil

local function get_window_dimensions()
  local fw = options.floating_window
  if fw.fullscreen then
    return vim.o.columns, vim.o.lines - 1, 0, 0
  end
  local f = fw.scaling_factor
  local h = math.ceil(vim.o.lines * f) - 1
  local w = math.ceil(vim.o.columns * f)
  return w, h, math.ceil(vim.o.lines - h) / 2, math.ceil(vim.o.columns - w) / 2
end

local function open_floating_window()
  local fw = options.floating_window
  local w, h, r, c = get_window_dimensions()

  local buf = api.nvim_create_buf(false, true)
  local new_win = api.nvim_open_win(buf, true, {
    style = "minimal",
    relative = "editor",
    row = r,
    col = c,
    width = w,
    height = h,
    border = fw.fullscreen and "none" or fw.border,
  })

  vim.bo[buf].filetype = "lumen"
  vim.bo[buf].bufhidden = "wipe"
  vim.wo[new_win].cursorcolumn = false
  vim.wo[new_win].signcolumn = "no"

  api.nvim_set_hl(0, "LumenBorder", { link = "Normal", default = true })
  api.nvim_set_hl(0, "LumenFloat", { link = "Normal", default = true })
  vim.wo[new_win].winhl = "FloatBorder:LumenBorder,NormalFloat:LumenFloat"
  vim.wo[new_win].winblend = fw.winblend

  local augroup = api.nvim_create_augroup("LumenResize", { clear = true })
  api.nvim_create_autocmd("VimResized", {
    group = augroup,
    callback = function()
      if not api.nvim_win_is_valid(new_win) then
        api.nvim_del_augroup_by_id(augroup)
        return
      end
      local nw, nh, nr, nc = get_window_dimensions()
      api.nvim_win_set_config(new_win, {
        width = nw,
        height = nh,
        relative = "editor",
        row = nr,
        col = nc,
      })
    end,
  })

  return new_win, buf
end

local function on_exit(_, code, _)
  if code ~= 0 then
    return
  end

  vim.cmd("silent! checktime")

  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  if vim.api.nvim_win_is_valid(prev_win) then
    vim.api.nvim_set_current_win(prev_win)
  end

  prev_win = -1
  win = -1
end

local function lumen_diff(args)
  if lumen_found == nil then
    lumen_found = vim.fn.executable("lumen") == 1
  end
  if not lumen_found then
    vim.notify("lumen is not installed. See https://github.com/jnsahaj/lumen", vim.log.levels.ERROR)
    return
  end

  prev_win = vim.api.nvim_get_current_win()
  win = open_floating_window()

  local cmd = { "lumen", "diff" }
  for _, arg in ipairs(args) do
    table.insert(cmd, arg)
  end

  vim.fn.jobstart(cmd, { term = true, on_exit = on_exit })
  vim.cmd("startinsert")
end

local function lumen_diff_current_file(args)
  local file = vim.fn.expand("%:.")
  if file == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    lumen_diff(args)
    return
  end

  local combined = { "--focus", file }
  for _, arg in ipairs(args) do
    table.insert(combined, arg)
  end
  lumen_diff(combined)
end

local function setup(opts)
  options = vim.tbl_deep_extend("force", defaults, opts or {})
end

return {
  setup = setup,
  lumen_diff = lumen_diff,
  lumen_diff_current_file = lumen_diff_current_file,
}
