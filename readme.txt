//
//    Модуль компонента Graphic Assi Control
//    Copyright (c) 2013  Pichugin M.
//    
//    Разработчик: Pichugin M. (e-mail: pichugin-swd@mail.ru)
//
// ver. 0.33
// ver. 0.32
// - Изменен алгоритм линейки SuperRulerPaint();
// - Добавлено TDoVertexEditEvent
// - Добавлено Shore
// - Добавлено DocumentEntityOnEdit
// ver. 0.31
// - Заменен TEntityList.
// - Устранена утечка памяти
// ver. 0.30
// - Исправлена ошибка в AddMessageToUser и SetMessageToUser
// ver. 0.29
// - Добавлен TGraphicAttribute
// ver. 0.27
// - Доработка текста. Добавлен поворот текста, если он не ограничен рамками габарита
// - Добавлена функция RotateSCSPoint, RotateWCSPoint
// - Добавлено автоматическое перемещение объектов связанных по свойству GroupOwner
// ver. 0.24
// - Доработка алгоритма перемещения объектов
// ver. 0.23
// - Доработка алгоритма перемещения объектов
// - Добавлены стили работы курсора. Либо как в CAD,
//             либо компонент сам определяет из вариантов ОС,
//             либо вручную в основной программе
// - Добавлено свойство SelectObjectFilter
// ver. 0.22
// - Добавлена сетка
// ver. 0.20
// - Добавлен новый режим выбора
// ver. 0.19
// - Добавлена линейка   
//
// ver. 0.18.1
// - Добавлено масштабирование по X,Y,Z раздельно
// - Добавлен экспорт DXF
//
// ver. 0.18
// - Добавлены DataBitMap и DataBitMapEnabled
//
// ver. 0.17
// - Замена WheelData на WheelDelta
//
// ver. 0.16
// Добавлена функция создания рамки вокруг экрана с текстом в углу.
// Новые процедуры:
// - FrameViewModeSet
// - FrameViewModeClear
//
// ver. 0.15
// Обработка событий OnEvent переработана
//
// ver. 0.14
// Измена архитектура получения доступа объектов к классу TDrawDocumentCustom
// $mode objfpc
//
// ver. 0.13
// Исправлена ошибка указателя при выполнении Destroy
//
// ver. 0.12
// Добавлен Rotate в процедурах вывода текста
// Объявлены свойства цветов
// Новые процедуры:
// - OnBeforeDrawEvent
// - OnAfterDrawEvent
//
// ver. 0.11
// Добавлена функция вывода сообщений AddMessageToUser();
//
// ver. 0.10
// Новые процедуры:
// - OnEntityBeforeDrawEvent
// - OnEntityAfterDrawEvent

{  TODO LIST  }

 //todo: Не реализована функция поворота объектов по свойству Rotate
 //todo: Примитивно сделана арка
 //todo: Скорость скроллинга надо улучшить
 //todo: Выбор в лево и выбор в право не работает на блоках
 //      это связано с свойствами (SelectLeftColor, SelectRightColor)