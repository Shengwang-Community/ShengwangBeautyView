import UIAbility from '@ohos.app.ability.UIAbility'
import window from '@ohos.window'

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(stage: window.WindowStage): void {
    stage.loadContent('pages/BeautyMain')
    stage.getMainWindow().then((mainWindow: window.Window) => {
      mainWindow.setWindowKeepScreenOn(true)
      mainWindow.setWindowBackgroundColor('#1A1A2E')
      mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#1A1A2E', statusBarContentColor: '#FFFFFF',
        navigationBarColor: '#1A1A2E', navigationBarContentColor: '#FFFFFF'
      })
    })
  }
}
