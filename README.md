Vagrant Boxes
=============

This repository documents the setup proceedures the for the following downloadable Vagrant boxes:

#### Ubuntu Server 13.04 “Raring Ringtail”

This box is configured according to the suggested base box configuration and includes Chef and Puppet. If you're curious as to how it was configured, check out the [setup instructions][raring64setup] or take a look at the [shell script][raring64sh] used to create it.

Use the configuration below in your `Vagrantfile` or [download the base box][raring64box]
directly.

```
config.vm.box = "ubuntu-server-raring64"
config.vm.box_url = "https://copy.com/ihzTonCKxAiH/ubuntu-server-raring64.box"
```

[raring64sh]: https://github.com/Josiah/VagrantBoxes/blob/master/ubuntu-server-raring64.sh "Ubuntu Server 13.04 “Raring Ringtail” shell script"
[raring64setup]: http://josiah.github.io/VagrantBoxes/ubuntu-server-raring64.html "Ubuntu Server 13.04 “Raring Ringtail” setup instructions"
[raring64box]: https://copy.com/ihzTonCKxAiH "Ubuntu Server 13.04 “Raring Ringtail” base box download"

Why?
----

There are services which provide created boxes (such as [vagrantbox.es][1])
and there are tools to generate them from scripts (such as [veewee][2]). The
former aren't doesn't have any boxes which match my needs and I couldn't make
the latter install thanks to ruby dependency hell.

 [1]: http://vagrantbox.es
 [2]: https://github.com/jedi4ever/veewee

After trying with both to generate a working base box for Ubuntu Server 13.04
I gave up and did it manually. Rather than forgetting how I did it and having
to learn it again when I have to do it again I decided to document the
process. Taking it a step further, I documented the process as a shell script
so that I had less work to do next time.

