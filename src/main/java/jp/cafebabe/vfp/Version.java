package jp.cafebabe.vfp;

public class Version {
    private String version;

    private Version(String version) {
        this.version = version;
    }

    public String toString() {
        return version;
    }

    public static Version of(String version) {
        return new Version(version);
    }
}
