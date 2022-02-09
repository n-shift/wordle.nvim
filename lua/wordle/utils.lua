local utils = {}

function utils.wmap(lhs, rhs, buf)
    vim.api.nvim_buf_set_keymap(buf, "n", lhs, rhs,
    { noremap = true, silent = true })
end

return utils
