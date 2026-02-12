#include <tree_sitter/parser.h>
#include <stdbool.h>
#include <stdint.h>

enum TokenType {
    ASSEMBLY_BODY,
};

void
*tree_sitter_zenc_external_scanner_create(void) {
    return NULL;
}

void
tree_sitter_zenc_external_scanner_destroy(void *payload) {}

void
tree_sitter_zenc_external_scanner_reset(void *payload) {}

unsigned
tree_sitter_zenc_external_scanner_serialize(void *payload, char *buffer) {
    return 0;
}

void
tree_sitter_zenc_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) {}

bool
tree_sitter_zenc_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols) {
    if (!valid_symbols[ASSEMBLY_BODY])
        return false;
    uint32_t brace_depth = 1;

    while (true) {
        if (lexer->eof(lexer))
            return false;
        
        if (lexer->lookahead == '{') {
            brace_depth++;
        
        } else if (lexer->lookahead == '}') {
            brace_depth--;

            if (brace_depth == 0)
                return true;
        }

        lexer->advance(lexer, false);
    }
}
