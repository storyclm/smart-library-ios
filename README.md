# smart-library-ios #

SmartLibrary - это демонстрационное iOS приложение для доступа к контенту, созданного с помощью диджитал-платформы [StoryCLM](https://storyclm.com/)

### ContentComponent

В основе работы SmartLibrary лежит фреймворк [ContentComponent](https://github.com/storyclm/story-content-ios), отвечающий за синхронизацию и доступ к данным.

### Сборка

Для сборки и успешого запуска приложения необходим файл AuthCredentials.plist, который содержит в себе все необходимы данные для работы SCLMAuthService.

Файл AuthCredentials.plist необходимо добавить в проект SmartLibrary

Запросите этот файл у менеджера StoryCLM.

### Настройка

Для работы с ContentComponent необходимо установить SCLMAuthService и SCLMSyncService с данными из AuthCredentials.plist

```swift
SCLMAuthService.shared.setClientId(clientId)
SCLMAuthService.shared.setClientSecret(clientSecret)
SCLMAuthService.shared.setAppId(appId)
SCLMAuthService.shared.setAppSecret(appSecret)
SCLMAuthService.shared.setAuthEndpoint(authEndpoint)
```
