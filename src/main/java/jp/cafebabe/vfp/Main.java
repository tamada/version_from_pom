package jp.cafebabe.vfp;

import java.io.IOException;
import java.io.InputStream;
import java.lang.module.ModuleDescriptor;
import java.net.URL;
import java.util.Optional;
import java.util.Properties;
import java.util.function.Supplier;
import java.util.stream.Stream;

public class Main {
    private static final String VERSION = "1.0.0";

    @FunctionalInterface
    public interface VersionProvider extends Supplier<Pair<Version, String>> {
        Pair<Version, String> get();
    }

    public Main(String[] args) {
    }

    public void perform() {
        Stream.of(new ConstantVersionProvider(), new PropertyVersionProvider(),
                        new PackageVersionProvider(), new ModuleVersionProvider())
                .forEach(provider -> printResult(provider));
    }

    private void printResult(VersionProvider provider) {
        try {
            printResultImpl(provider);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void printResultImpl(VersionProvider provider) {
        var result = measure(() -> provider.get());
        Pair<Version, String> pair = result.right();
        String version = String.valueOf(pair.left());
        System.out.printf("%5s,%10d nano sec,%s%n", version, result.left(), pair.right());
    }

    private <R> Pair<Long, R> measure(Supplier<R> supplier) {
        long from = System.nanoTime();
        R result = supplier.get();
        return Pair.of(System.nanoTime() - from, result);
    }

    public static class ConstantVersionProvider implements VersionProvider {
        @Override
        public Pair<Version, String> get() {
            return Pair.of(Version.of(VERSION), "constant");
        }
    }

    public static class PropertyVersionProvider implements VersionProvider {
        @Override
        public Pair<Version, String> get() {
            URL url = getClass().getResource("/resources/vfp.properties");
            try (InputStream in = url.openStream()) {
                Properties p = new Properties();
                p.load(in);
                String version = p.getProperty("vfp.version");
                return Pair.of(Version.of(version), "properties");
            } catch (IOException e) {
                throw new InternalError(e);
            }
        }
    }

    public static class PackageVersionProvider implements VersionProvider {
        @Override
        public Pair<Version, String> get() {
            String version = getClass().getPackage().getImplementationVersion();
            return Pair.of(Version.of(version), "package");
        }
    }

    public static class ModuleVersionProvider implements VersionProvider {
        @Override
        public Pair<Version, String> get() {
            Optional<ModuleDescriptor.Version> version = getClass().getModule()
                    .getDescriptor().version();
            return Pair.of(Version.of(version.map(v -> v.toString())
                    .orElse("null")), "module");
        }
    }

    public static void main(String[] args) {
        new Main(args).perform();
    }
}
