Algowars
========
Trevor and Taylor's final project for Algorithms

Components
----------
The code is in `divider.rb`, this is the divider class that does all
the work. To use it, create a new instance with a string path to
a file, ie. `divider = Divider.new("/path/to/input.txt")`, then call
`divider.completion_time` to get the completion time. You can also access
`divider.n`, `divider.m`, `divider.times`, and `divider.speeds` once it
has been initialized.

Instructions
------------
1. Clone repo
2. `cd` into cloned repo and run `bundle install`
2. Test the code by running `rspec spec` 