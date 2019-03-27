# smart-library-ios #

SmartLibrary - это демонстрационное iOS приложение для доступа к контенту, созданного с помощью диджитал-платформы StoryCLM https://storyclm.com/

### ContentComponent

В основе работы SmartLibrary лежит фреймворк ContentComponent, отвечающий за синхронизацию и доступ к данным.
ContentComponent состоит из следующих модулей:

* SCLMAuthService - аутентификация
* SCLMSyncService - доступ к RESTful API StoryCLM
* SCLMSyncManager - менеджер синхронизации
* SCLMBridge - мост

### Сборка

Для сборки и успешого запуска приложения необходим файл AuthCredentials.plist, который содержит в себе все необходимы данные для работы SCLMAuthService.

Файл AuthCredentials.plist необходимо добавить в проект SmartLibrary

Запросите этот файл у менеджера StoryCLM.

### Настройка

Для работы с ContentComponent необходимо установить SCLMAuthService и SCLMSyncService с данными из AuthCredentials.plist

```
    SCLMAuthService.shared.setClientId(clientId)
    SCLMAuthService.shared.setClientSecret(clientSecret)
    SCLMAuthService.shared.setAppId(appId)
    SCLMAuthService.shared.setAppSecret(appSecret)
    SCLMAuthService.shared.setAuthEndpoint(authEndpoint)
```

### Логин

Для логина необходимо вызвать следующий метод

```
    SCLMAuthService.shared.auth(username: username, password: password, success: { (token) in
        success()

    }) { (error) in
        failure(error)

    }
```
        
При успешной аутентификации быдет получен token, который в дальнейшем будет использован SCLMSyncService для доступа к RESTful API
        
### Синхронизация Клиентов

После успешного логина необходим выполнить синхронизацию клиентов

```
    SCLMSyncManager.shared.synchronizeClients { (error) in

    }
```

Данный метод загрузит всех доступных клиентов и презентации для каждого клиента

### Доступ к данным

Доступ к данным предоставляет NSFetchedResultsController<NSFetchRequestResult> 

```
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        return SCLMSyncManager.shared.fetchedResultsController
    }
```

Количество Клиентов (Client) - это количество секций для UITableViewDataSource или UICollectionViewDataSource

```
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if let sections = viewModel.fetchedResultsController.sections {
            return sections.count
        }
        return 0
        
    }
```

Количество объектов секции (Presentation) - это презентации Клиентов.

```
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let sections = viewModel.fetchedResultsController.sections {
            if sections.count > section {
                return sections[section].numberOfObjects
            }
        }
        return 0
        
    }
```

Доступ к презентации осуществляется через

```
let presentation = fetchedResultsController.object(at: indexPath) as! Presentation
```

### Синхронизация презентаций

При синхронизации клиентов синхронизируются только модели презентаций. Для синхронизации контента презентации неодходимо вызвать

```
    SCLMSyncManager.shared.synchronizePresentation(presentation, completionHandler: { (error) in
        completionHandler(error)

    }) { (progress) in
        progressHandler(progress)

    }
```

Для восстановления прогреса синхронизации при обновлении данных необходимо воспользоваться следующими инструментами:

```
    let contentPackageDownloadingNow = SCLMSyncManager.shared.isContentPackageDownloadingNow(contentPackageId: presentation.contentPackage?.contentPackageId, presentationId: presentation.presentationId)
```

Если контент загружается в настоящий момент, то метод isContentPackageDownloadingNow вернет объект, у которого есть следующие свойства

```
    public weak var downloadRequest: DownloadRequest?
    public var progress = Progress() {
        didSet {
            progressHandler?(presentationId.intValue, progress)
        }
    }
    public var progressHandler: ((_ presentationId: Int?, _ progress: Progress) -> Void)?
    public var completionHandler: ((_ presentationId: Int?) -> Void)?
```

Соответственно, для downloadRequest может быть вызван cancel() для отмены, progress - передает текущий прогресс, progressHandler и completionHandler можно использовать для упраления процессом и обновления интерфейса

Для удаления контента необходимо вызвать

```
    SyncManager.shared.deletePresentationContentPackage(presentation)
```

Для обновления презентации необходимо вызвать

```
    SCLMSyncManager.shared.updatePresentation(presentation) { (error) in
        completionHandler(error)
    }
```



