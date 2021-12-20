import {
    DirPath,
    Installer,
    Url,
    Version,
    dirPathIso,
    urlIso,
} from '@setup-cljstyle/domain-models';

const installerForWin32: Installer = () => {
    return Promise.resolve(dirPathIso.wrap(''));
};

const installerForDarwin: Installer = () => {
    /* eslint-disable @typescript-eslint/no-unused-vars */
    const binDir: DirPath = dirPathIso.wrap('/home/runner/.local/bin');

    const downloadUrl = (version: Version): Url =>
        /* eslint-enable @typescript-eslint/no-unused-vars */
        urlIso.wrap(
            `http://github.com/greglook/cljstyle/releases/download/${version}/cljstyle_${version}_linux.tar.gz`
        );

    return Promise.resolve(dirPathIso.wrap(''));
};

const installerForLinux: Installer = () => {
    return Promise.resolve(dirPathIso.wrap(''));
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
