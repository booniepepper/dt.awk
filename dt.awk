#!/usr/bin/awk -f

function init_ctx() {
    split("", ctx)
    ctxptr = 1
}

function push(value) {
    ctxptr++
    ctx[ctxptr] = value
}

function pop() {
    # TODO: Error on stack underflow?
    val = ctx[ctxptr]
    ctxptr--
    return val
}

function eval(line) {
    # TODO: This splits only whitespace. Handle strings and escapes, and handle
    # the characters [ ] : outside strings as unique tokens even if they have
    # no adjacent whitespace.
    n = split(line, toks)

    for (i = 1; i <= n; i++) {
        token = toks[i]
        if (token ~ /^[0-9]+$/) {
            # integers
            push(token)
        } else if (token ~ /^[\+\-\*\/]$/) {
            # math operators
            # TODO: Make these into functions?
            b = pop()
            a = pop()
            switch (token) {
                case "+": push(a + b) ; break
                case "-": push(a - b) ; break
                case "*": push(a * b) ; break
                case "/": push(a / b) ; break
            }
        } else {
            print "ERR: unknown command $token"
            exit 1
        }
    }

    printf("DEBUG: status [ ")
    for (i in ctx) printf("%d ", ctx[i])
    printf("]\n")
}

BEGIN {
    init_ctx()

    split("", args)
    
    for (i = 2; i < ARGC; i++) {
        args[i - 1] = ARGV[i]
    }

    delete ARGV
}

{ push($0) }

END {
    for (i = 0; i < ARGC - 1; i++) {
        eval(args[i])
    }
    
    if (ctxptr >= 1) {
        last = pop()
	printf("%s\n", last)
    }
}

