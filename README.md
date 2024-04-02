# DockerImages

### Setup no Packer

```lua
use({
  'antonioanerao/dockerimages.nvim',
  config = function()
    require('dockerimages').setup()
  end,
})
```

### Comando para ver imagens

Aperta : no seu nvim e digite...
```lua
:Docker Images
```
### Atalho para ver imagens

```lua
<Leader>di
```
