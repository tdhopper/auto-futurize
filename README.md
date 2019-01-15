# Auto-Futurize

Apply python-future.org's [futurize tool](https://python-future.org/automatic_conversion.html) one fix at a time, running tests and making a commit each time a fix has been applied.

To test on this sample project, ensure you have `tox` installed and run

```
$ ./auto-futurize.sh
```

Once this has completed, type `git log` to see the history of modifications to your code.

Use on your own project by copy and pasting auto-futurize.sh and configuring the variables at the top.
