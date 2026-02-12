// SPDX-FileCopyRightText: 2026 Will Reed <wreed@disroot.org>
// SPDX-License-Identifier: LGPL-3.0-or-later

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
    extras: $ => [/\s|\\\r?\n/, $.comment],
    conflicts: $ => [
        [$.expression],
        [$.return, $.value],
        [$.isolated_expression, $.value],
        [$.isolated_expression, $.expression],
        [$.assignment, $.value],
        [$.return]
    ],
    externals: $ => [
        $.assembly_body,
    ],
    name: "zenc",
    rules: {
     
        document: $ => optional(
            repeat1(
                choice(
                    $.statement,
                    $.definition,
                    $.builtin
                )
            )
        ),

        type: $ =>
            choice(
                'int', 'uint',
                'c_char', 'c_uchar',
                'c_short', 'c_ushort',
                'c_int', 'c_uint',
                'c_long', 'c_ulong',
                'c_long_long', 'c_ulong_long',
                'i8', 'i16', 'i32', 'i64', 'i128',
                'I8', 'I16', 'I32', 'I64', 'I128',
                'u8', 'u16', 'u32', 'u64', 'u128',
                'U8', 'U16', 'U32', 'U64', 'U128',
                'isize', 'usize', 'byte',
                'f32', 'F32',
                'f64', 'F64',
                'u0', 'U0', 'void',
                'char',
                'bool',
                'string',
                'float',
                "Vec",
                "String"
            ),

        std_function: $ => choice(
            'print',
            'println',
        ),

        type_descriptor: $ => seq(
            "<",
            sep1(choice($.name, $.type, $.value), ","),
            ">"
        ),

        // bare_call: $ => seq(
        //     $.bare_callable_function,
        //     $.quoted
        // ),
    
        operation: $ => choice(
            token('/'),
            token('*'),
            token('-'),
            token('+')
        ),

        member: $ => seq($.name, ':', $.type_annotation, ';'),
        struct: $ => seq(
            optional('opaque'),
            'struct',
            $.name,
            '{',
            optional(repeat1($.member)),
            '}'
        ),

        number: $ => choice(
            token(/[0-9]+(\.[0-9]+)?/),
            token(/0x[A-F0-9]+/)
        ),
        
        definition_parameters: $ => choice(
            sep1(choice($.name,seq($.name, ':', $.type_annotation)), ','),
        ),

        import: $ => seq(
            'import',
            $.quoted,
        ),
    
        alias: $ => seq(
            optional($.builtin_modifier),
            "alias",
            $.name,
            "=",
            choice($.type_annotation, $.name),
        ),
        
        assembly_block: $ => seq(
            "asm",
            optional($.builtin_modifier),
            "{",
            $.assembly_body,
            "}"
        ),

        builtin_modifier: $ => choice(
            'opaque',
            'volatile'
        ),

        builtin: $ => seq(
            choice($.import, $.alias, $.assembly_block),
            optional(";")
        ),

        enum_member: $ => seq(
            $.name,
            optional(seq(
                token.immediate('('),
                sep1($.type_annotation, ','),
                ')'
            )),
        ),

        reserved_identifier: $ => choice(
            "_Atomic",
            "_Bool",
            "_Complex",
            "_Generic",
            "_Imaginary",
            "_Noreturn",
            "_Static_assert",
            "_Thread_local"
        ),

        module_resolver: $ => '::',

        operator_literal: $ => choice('and', 'or'),


        type_modifier: $ => choice(
            'const',
            'unsigned',
            'signed',
            'short',
            'long',
            seq('long', 'long')
        ),

        statement_modifier: $ => choice(
            'restrict',
            'extern',
            'auto',
            'autofree',
            'inline',
        ),


        return: $ => seq(
            token('return'),
            optional(choice(
                $.value,
                $.name,
                $.expression
            ))
        ),

        enum: $ => seq(
            'enum',
            $.name,
            '{',
            // optional(repeat1($.enum_member)),
            optional(sep1($.enum_member, ',')),
            '}'
        ),

        union: $ => seq(
            'union',
            $.name,
            '{',
            optional(repeat1($.member)),
            '}'
        ),

        trailing_return: $ => seq(
            '->',
            choice(
                $.name,
                $.type_annotation,
            )
        ),

        call_parameters: $ => choice(
            sep1(choice(
                $.name,
                $.value,
                seq($.name, ':', $.value)
            ), ',')
        ),

        function_call: $ => choice(
            $.bare_function_call,
            seq(
                $.name,
                "(",
                optional($.call_parameters),
                ")"
            )
        ),

        function_signature: $ => seq(
            "fn",
            field('signature_name', $.name),
            "(", optional($.definition_parameters), ")",
            optional(field('return_type', $.trailing_return))
        ),

        function_body: $ => seq(
            "{",
            repeat1(choice(
                $.statement,
                $.definition,
                $.builtin,
            )),
            "}",
        ),


        bare_function_call: $ => seq(
            choice("print", "println"),
            $.quoted
        ),

        function: $ => seq(
            $.function_signature,
            optional($.function_body)
        ),

        isolated_expression: $ => seq(
            '(',
            choice($.value, $.name),
            $.operation,
            choice($.value, $.name, $.expression),
            ')'
        ),

        expression: $ => seq(
            choice($.value, $.name, $.isolated_expression),
            $.operation,
            choice($.value, $.name, $.isolated_expression)
        ),
        
        lambda: $ => seq(
            $.name,
            '->',
            $.expression
        ),

        block_lambda: $ => prec(1, seq(
            'fn',
            '(',
            optional($.definition_parameters),
            ')',
            $.trailing_return,
            '{',
            optional(repeat1(choice($.statement, $.builtin))),
            '}'
        )),


        modifier: $ => choice('opaque', 'const'),

        string: $ => token.immediate(prec(1, /[^\\"'\n]+/)),
        quoted: $ => choice(
            seq('"', repeat($.string), '"'),
            seq("'", repeat($.string), "'")
        ),

        boolean: $ => choice('true', 'false'),
        null: $ => 'null',


        type_annotation: $ => seq(
            optional($.type_modifier),
            $.type,
            optional($.type_descriptor)
        ),

        value: $ => choice(
            $.number,
            $.quoted,
            $.tuple,
            $.boolean,
            $.null,
            $.expression,
            $.function_call
        ),
        
        name: $ => token(/[_A-Za-z][A-Za-z\-_0-9]*/),

        definition: $ => seq(
            choice($.struct, $.function, $.union, $.enum),
            optional(";")
        ),
        declarator: $ => choice("let", "def"),

        lambda_expression: $ => seq('=', $.lambda),
        block_lambda_expression: $ => seq('=', $.block_lambda),
        assignment: $ => seq(
            '=',
            choice($.value, $.name, $.expression)
        ),

        statement: $ => seq(
            choice(
                $.return,
                $.function_call,
                seq(
                    $.declarator,
                    $.identifier,
                    optional(
                        choice(
                            $.lambda_expression,
                            $.block_lambda_expression,
                            $.assignment
                        )
                    )
                )
            ),
            optional(";")
        ),

        tuple: $ => seq(
            '(',
            sep1(choice($.value, $.name), ','),
            ')'
        ),

        identifier_tuple: $ => seq(
            '(',
            sep1(
                choice($.name, $.identifier_with_type),
                ','
            ),
            ')'
        ),

        identifier_with_type: $ => seq(
            $.name, ':', $.type_annotation
        ),

        identifier: $ => choice(
            $.name,
            $.identifier_with_type,
            $.identifier_tuple
        ),


        comment: _ => token(
            choice(
                seq('//', /(\\+(.|\r?\n)|[^\\\n])*/),
                seq('/*', /[^*]*\*+([^/*][^*]*\*+)*/, '/')
            )
        )
    }
});

function sep1(rule, separator) {
    return seq(rule, repeat(seq(separator, rule)));
}

function sep(rule, separator) {
    return optional(sep1(rule, separator));
}
