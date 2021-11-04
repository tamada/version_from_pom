# version_from_pom

This product is to examine how to get version defined in `pom.xml`.
Details are shown in my blog https://tamada.github.io/blog/20211104-vfp (In Japanese).

To conduct the experiment, run `exec_experiment.sh`.
The script do the followings.

* Show message (`-h` option)
* Clean up (`-c` and `-C` option)
* Rebuild (`-r` and `-R` option)
* Execute the experiment
    1. Compile the project by maven.
    2. Create versioned module by `module-info.class` from `jmod`.
    3. Create the native image.
        * with `-jar` option for the jar by the maven.
        * with `--module` option for the jar by the maven.
        * with `-jar` option for the jar by the step 2.
        * with `--module` option for the jar by the step 2.

### Usage of the script

```shell
execute experiments. details are shown in https://tamada.github.io/blog/20211105-vfp
exec_experiment.sh [OPTIONS]
OPTIONS
    -h      print this message.
    -c      clean the products
    -C      clean all
    -r      clean and re-build
    -R      clean all and re-build
```

