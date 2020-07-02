# Beatussum's Kali Linux configuration

## About this

My custom configuration making some changes to the [official **Kali Linux** configuration](https://gitlab.com/kalilinux/build-scripts/live-build-config/) and adding some applications that I use (for further information about the packages installed, please see [_kali-config/variant-bsum/package-lists/kali.list.chroot_](https://github.com/beatussum/live-build-config/blob/master/kali-config/variant-bsum/package-lists/kali.list.chroot))

## Building

### Dependencies

- **curl**
- **git**
- **live-build**
- **cdebootstrap**

### Building

1. Choose a mirror from [official **Kali Linux** mirrors](http://http.kali.org/README.mirrorlist) and put it into a file named _.mirror_

2. **OPTIONAL** If you want to build the image with the last **Kali Linux** upstream files, you can just delete the file named _.lock_. **WARNING** The build can fail.

3. Just build…

```bash
make HOSTNAME=<what_you_want> USERNAME=<what_you_want> FULLNAME=<what_you_want>
```

4. You have now a file named _bsum-kali-${LB_ARCHITECTURE}.hybrid.iso_
