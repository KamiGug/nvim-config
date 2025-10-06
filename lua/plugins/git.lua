return {
  "braxtons12/blame_line.nvim",
  event = "VeryLazy",
  opts = function()
    return {
      show_in_visual = true,
      show_in_insert = true,
      prefix = " ",

      -- String specifying the the blame line format.
      -- Any combination of the following specifiers, along with any additional text.
      --     - `"<author>"` - the author of the change.
      --     - `"<author-mail>"` - the email of the author.
      --     - `"<author-time>"` - the time the author made the change.
      --     - `"<committer>"` - the person who committed the change to the repository.
      --     - `"<committer-mail>"` - the email of the committer.
      --     - `"<committer-time>"` - the time the change was committed to the repository.
      --     - `"<summary>"` - the commit summary/message.
      --     - `"<commit-short>"` - short portion of the commit hash.
      --     - `"<commit-long>"` - the full commit hash.
      template = "<author> at <author-time> • <summary>",

      date = {
        relative = false,

        format = "%H:%M:%S %d-%m-%y",
      },

      hl_group = "BlameLineNvim",
      delay = 0,
    }
  end,
}
