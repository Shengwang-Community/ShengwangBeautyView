import { common } from '@kit.AbilityKit'
import window from '@ohos.window'

export function setBeautyWindowColor(context: common.UIAbilityContext, color: string): void {
  window.getLastWindow(context).then((mainWindow: window.Window) => {
    mainWindow.setWindowBackgroundColor(color)
    return mainWindow.setWindowSystemBarProperties({
      statusBarColor: color, statusBarContentColor: '#FFFFFF',
      navigationBarColor: color, navigationBarContentColor: '#FFFFFF'
    })
  }).catch((error: Error) => {
    console.warn(`[BeautyDemo] window style failed: ${error.message}`)
  })
}
