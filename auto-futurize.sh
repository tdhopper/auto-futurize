#!/bin/bash
set -ex

########################################
########################################
########## USER CONFIGURATION ##########

PYTHON2_TEST_COMMAND="tox -e py27"
PYTHON3_TEST_COMMAND="tox -e py36"
FUTURIZE_PATH=./.tox/py36/bin/futurize
CODE_DIRECTORIES="./project/ ./tests/"
BRANCH_NAME=py2-3-compatibility

########################################
########################################

git checkout $BRANCH_NAME || git co -b $BRANCH_NAME
$PYTHON2_TEST_COMMAND

STAGE1_FIXES=(lib2to3.fixes.fix_apply lib2to3.fixes.fix_except lib2to3.fixes.fix_exec lib2to3.fixes.fix_exitfunc lib2to3.fixes.fix_funcattrs lib2to3.fixes.fix_has_key lib2to3.fixes.fix_idioms lib2to3.fixes.fix_intern lib2to3.fixes.fix_isinstance lib2to3.fixes.fix_methodattrs lib2to3.fixes.fix_ne lib2to3.fixes.fix_numliterals lib2to3.fixes.fix_paren lib2to3.fixes.fix_reduce lib2to3.fixes.fix_renames lib2to3.fixes.fix_repr lib2to3.fixes.fix_standarderror lib2to3.fixes.fix_sys_exc lib2to3.fixes.fix_throw lib2to3.fixes.fix_tuple_params lib2to3.fixes.fix_types lib2to3.fixes.fix_ws_comma lib2to3.fixes.fix_xreadlines libfuturize.fixes.fix_absolute_import libfuturize.fixes.fix_next_call libfuturize.fixes.fix_print_with_import libfuturize.fixes.fix_raise)
STAGE2_FIXES=(lib2to3.fixes.fix_dict lib2to3.fixes.fix_filter lib2to3.fixes.fix_getcwdu lib2to3.fixes.fix_input lib2to3.fixes.fix_itertools lib2to3.fixes.fix_itertools_imports lib2to3.fixes.fix_long lib2to3.fixes.fix_map lib2to3.fixes.fix_next lib2to3.fixes.fix_nonzero lib2to3.fixes.fix_operator lib2to3.fixes.fix_raw_input lib2to3.fixes.fix_zip libfuturize.fixes.fix_basestring libfuturize.fixes.fix_cmp libfuturize.fixes.fix_division_safe libfuturize.fixes.fix_execfile libfuturize.fixes.fix_future_builtins libfuturize.fixes.fix_future_standard_library libfuturize.fixes.fix_future_standard_library_urllib libfuturize.fixes.fix_metaclass libfuturize.fixes.fix_object libfuturize.fixes.fix_unicode_keep_u libfuturize.fixes.fix_xrange_with_import libpasteurize.fixes.fix_newstyle)

# Do stage 1 futurize migration ("Modernize Python 2 code only;
# no compatibility with Python 3")

for fix in "${STAGE1_FIXES[@]}"; do
    echo "Attempting $fix"
    $FUTURIZE_PATH --stage2 --write --fix "$fix" $CODE_DIRECTORIES
    if [[ $(git diff --stat) != '' ]]; then
        if $PYTHON2_TEST_COMMAND
        then
            git add -u && git commit -m "Apply futurize $fix" || true
        else
            echo "Python 2 test failure while applying $fix."
            exit 1
        fi
    fi
done
git tag -a py2-modernized -m"Python 2 code is modernized"

# Do stage 2 futurize migration ("Take modernized (stage1) code and
# add a dependency on ``future`` to provide Py3 compatibility.")

for fix in "${STAGE2_FIXES[@]}"; do
    echo "Attempting $fix"
    $FUTURIZE_PATH --stage2 --write --fix "$fix" $CODE_DIRECTORIES
    if [[ $(git diff --stat) != '' ]]; then
        if $PYTHON2_TEST_COMMAND
        then
            git add -u && git commit -m "Apply futurize $fix" || true
        else
            echo "Python 2 test failure while applying $fix."
            exit 1
        fi
    fi
done

$PYTHON3_TEST_COMMAND
git tag -a py3-compatible -m"Tests pass in Python 2 and 3"
