package tree_sitter_zenc_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_zenc "codeberg.org/wreedb/tree-sitter-zenc/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_zenc.Language())
	if language == nil {
		t.Errorf("Error loading Zen-C grammar")
	}
}
