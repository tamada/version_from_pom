package jp.cafebabe.vfp;

import java.util.function.BiFunction;

public class Pair<L, R> {
    private L left;
    private R right;

    private Pair(L left, R right) {
        this.left = left;
        this.right = right;
    }

    public R right() {
        return unify((l, r) -> r);
    }

    public L left() {
        return unify((l, r) -> l);
    }

    public <T> T unify(BiFunction<L, R, T> mapper) {
        return mapper.apply(left, right);
    }

    public static <L, R> Pair<L, R> of(L left, R right) {
        return new Pair<>(left, right);
    }
}
