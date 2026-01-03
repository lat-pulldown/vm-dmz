**Visit [here](https://lat-pulldown.github.io/otlab) for user guide.**  

For the full setup, use [otlab](https://github.com/lat-pulldown/otlab) with this repo for setting up the local enviornment.

---

Shell script for setting up multipass VM. Contains Conpot, Thingsboard, and Caldera.   

Please note that this shell script is optimized for Apple Silicon (ARM-based macOS). If you are using an Intel-based Mac, Windows (AMD/Intel), or Linux machine, some commands—especially Docker image tags or architecture-specific settings—may need to be adjusted accordingly.

## Initial Setup
### Install [Multipass](https://canonical.com/multipass)
From Homebrew Terminal
```
brew install --cask multipass
```
Verify with `multipass version` and `multipass list`
### Create a VM
```
multipass launch lts \
  --name dmz \
  --cpus 4 \
  --memory 8G \
  --disk 40G
```
### Enter the shell
```
multipass shell dmz
```
`multipass stop dmz` to stop `dmz`, `multipass start dmz` to start again.  
### Clone this [Github](https://github.com/lat-pulldown/vm-dmz)
```
git clone https://github.com/lat-pulldown/vm-dmz.git
```
### Build Conpot, Thingsboard, and Caldera (Use different terminals for each)
```
chmod +x setup_XXX.sh
./setup_XXX.sh
```

## Citation
- DeepLog - [wuyifan18/DeepLog](https://github.com/wuyifan18/DeepLog)
- Conpot - [mushorg/conpot](https://github.com/mushorg/conpot)
- Thingsboard - [thingsboard/thingsboard](https://github.com/thingsboard/thingsboard)
- Caldera - [mitre/caldera](https://github.com/mitre/caldera)
- Caldera OT-Plugins - [mitre/caldera-ot](https://github.com/mitre/caldera-ot)  
