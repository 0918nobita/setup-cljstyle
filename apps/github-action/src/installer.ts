import {
    Installer,
    Url,
    Version,
    wrapDirPath,
    wrapUrl,
} from '@setup-cljstyle/domain-models';

const installerForWin32: Installer = () => {
    return Promise.resolve(wrapDirPath(''));
};

const installerForDarwin: Installer = () => {
    /* eslint-disable @typescript-eslint/no-unused-vars */
    const binDir = wrapDirPath('/home/runner/.local/bin');

    const downloadUrl = (version: Version): Url =>
        /* eslint-enable @typescript-eslint/no-unused-vars */
        wrapUrl(
            `http://github.com/greglook/cljstyle/releases/download/${version}/cljstyle_${version}_linux.tar.gz`
        );

    return Promise.resolve(wrapDirPath(''));
};

const installerForLinux: Installer = () => {
    return Promise.resolve(wrapDirPath(''));
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
