-- Stan: ensure blank line at end of file
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.stan",
  callback = function()
    local bufnr = 0
    local last_line_nr = vim.api.nvim_buf_line_count(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    
    -- Find the last non-empty line
    local last_content_line = last_line_nr
    for i = last_line_nr, 1, -1 do
      if lines[i] and lines[i]:match("%S") then
        last_content_line = i
        break
      end
    end
    
    -- Remove all lines after the last content line
    if last_content_line < last_line_nr then
      vim.api.nvim_buf_set_lines(bufnr, last_content_line, -1, false, {})
    end
    
    -- Add exactly one blank line
    vim.api.nvim_buf_set_lines(bufnr, last_content_line, last_content_line, false, {""})
  end,
})
