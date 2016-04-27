# fpm-cookbook

fpm is a great tool and a great abstraction point for creating packages.

https://github.com/jordansissel/fpm

Given the bug promise and consistent interfaces this cookbook exists to extend fpm
into chef in a very non-intrusive way using an rbenv ruby.  It is abstracted with resources contained in /libraries.

It has reasonable defaults and those defaults are geared toward centos based systems.

```
fpm 'package_name' do
  sources '/usr/local/package/'
  output_dir '/tmp/'
end
```
This would output a package called package_name.rpm in /tmp/

```
fpm 'package_name' do
  sources '/usr/local/package/'
  output_dir '/tmp/'
  output_type 'deb'
end
```
this would output a package called package_name.deb in /tmp/


Please feel free to email me at louthebrew@gmail.com if you would like to suggested changes.
PR's graciously accepted and considered.
