# Clean and create build dir
rm -rf build >& /dev/null 
mkdir -p build

# compile bootloader 
nasm -f bin boot.asm -o build/boot.bin


dd if=/dev/zero of=build/fdisk.img bs=512 count=2880 
mkfs.fat -F 12 -n "SIMPLEOS" build/fdisk.img
dd if=build/boot.bin of=build/fdisk.img conv=notrunc 


