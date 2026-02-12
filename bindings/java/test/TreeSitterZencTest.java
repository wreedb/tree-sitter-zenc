import io.github.treesitter.jtreesitter.Language;
import io.github.treesitter.jtreesitter.zenc.TreeSitterZenc;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

public class TreeSitterZencTest {
    @Test
    public void testCanLoadLanguage() {
        assertDoesNotThrow(() -> new Language(TreeSitterZenc.language()));
    }
}
