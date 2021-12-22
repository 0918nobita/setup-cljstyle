import {
    Installer,
    version,
    dirPath,
    url,
} from '@setup-cljstyle/domain-models';

const installerForWin32: Installer = () => {
    return Promise.resolve(dirPath.iso.wrap(''));
};

const installerForDarwin: Installer = () => {
    /* eslint-disable @typescript-eslint/no-unused-vars */
    const binDir = dirPath.iso.wrap('/home/runner/.local/bin');

    const downloadUrl = (version: version.T): url.T =>
        /* eslint-enable @typescript-eslint/no-unused-vars */
        url.iso.wrap(
            `http://github.com/greglook/cljstyle/releases/download/${version}/cljstyle_${version}_linux.tar.gz`
        );

    return Promise.resolve(dirPath.iso.wrap(''));
};

const installerForLinux: Installer = () => {
    return Promise.resolve(dirPath.iso.wrap(''));
};

export const getInstaller = (p: NodeJS.Platform): Installer => {
    switch (p) {
        case 'win32':
            return installerForWin32;
        case 'darwin':
            return installerForDarwin;
        default:
            return installerForLinux;
    }
};
