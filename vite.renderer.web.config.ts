import type { UserConfig } from 'vite';
import rendererConfig from './vite.renderer.config';

export default async function config(): Promise<UserConfig> {
  const resolved = await rendererConfig({
    command: 'build',
    mode: 'production',
    root: process.cwd(),
    isPreview: false,
    isSsrBuild: false,
    forgeConfig: {
      renderer: [
        {
          name: 'main_window',
          config: 'vite.renderer.config.ts',
        },
      ],
    },
    forgeConfigSelf: {
      name: 'main_window',
      config: 'vite.renderer.config.ts',
    },
  } as never);

  return {
    ...resolved,
    define: {
      ...resolved.define,
      MAIN_WINDOW_VITE_NAME: JSON.stringify('main_window'),
      MAIN_WINDOW_VITE_DEV_SERVER_URL: undefined,
    },
  };
}
