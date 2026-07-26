# tldr

> I elected for the tldr client `tealdeer` for the ability to add custom pages and patches.
>
> I do wish that tealdeer offered better customisation of short/long options shown, directory paths,
> maximum columns, and formatting in general.
>

- List all pages in the cache:

`tldr --list`

- Browse tldr pages (I've written a custom function such that `tldr` invoked alone does this):

`tldr --list | fzf --preview "tldr {1} --color=always" --preview-window=right,70% | xargs tldr`

- Edit custom page/patch:

`tldr --edit-page {{command}}`

`tldr --edit-patch {{command}}`

- Render markdown as tldr-page:

`tldr --render {{path/to/file.md}}`

- Ignore/Override tealdeer's rendering:

`tldr --raw {{command}}`

`tldr --raw {{command}} | glow`

