#Использовать 1connector

#Область ПрограммныйИнтерфейс

// Получает версию сервера хранилища конфигурации
//
// Параметры:
//   Адрес          - Строка   - URL-ссылка на сервер хранилищ
//
// Возвращаемое значение:
//   Строка        - Версия сервера хранилища конфигураций
//
Функция ВерсияСервераХранилища(Знач Адрес) Экспорт
	
	Параметры = Новый Структура;
	Параметры.Вставить("ИмяХранилища", "getVersion");
	Параметры.Вставить("ВерсияПлатформы", "0.0.0.0");
	
	ТелоЗапроса = МенеджерЗапросов.ТелоЗапросаНаОткрытиеХранилища(Параметры);
	
	Ответ = КоннекторHTTP.Post(Адрес, ТелоЗапроса);
	ТекстОтвета = Ответ.Текст();

	Если Ответ.КодСостояния = 200 Тогда
		ОтветСервиса = ОбработкаXML.ПрочитатьОтветИзТекста(ТекстОтвета);
		
		Если ОтветСервиса.ЕстьОшибка Тогда
			ВерсияСервера = Вспомогательный.ВерсияСервераХранилища(ОтветСервиса.СодержаниеОшибки);
			Если ВерсияСервера = Неопределено Тогда
				ВызватьИсключение(ТекстОтвета);
			КонецЕсли;

			Возврат ВерсияСервера;
		КонецЕсли;
		
	Иначе
		ВызватьИсключение(ТекстОтвета);
	КонецЕсли;
	
	Возврат "0.0.0.0";
	
КонецФункции // ВерсияСервераХранилища()

// Проверяет существование хранилища 1С
//
// Параметры:
//   Адрес          - Строка   - URL-ссылка на сервер хранилищ
//   ИмяХранилища   - Строка   - имя хранилища. Например: `MyTrade` или `Trade/MyRepo`.
//   ВерсияПлатформы - Строка - версия платформы 1С. Например: 8.3.12.1855
//
// Возвращаемое значение:
//   Булево        - Истина - хранилище существует;
//                   Ложь - в противном случае.
//
Функция ХранилищеСуществует(Знач Адрес, Знач ИмяХранилища, ВерсияПлатформы) Экспорт
	
	Параметры = Новый Структура;
	Параметры.Вставить("ИмяХранилища"   , ИмяХранилища);
	Параметры.Вставить("ВерсияПлатформы", ВерсияПлатформы);
	
	ТелоЗапроса = МенеджерЗапросов.ТелоЗапросаНаОткрытиеХранилища(Параметры);
	
	Ответ = КоннекторHTTP.Post(Адрес, ТелоЗапроса);
	Если Ответ.КодСостояния = 200 Тогда
		ОтветСервиса = ОбработкаXML.ПрочитатьОтветИзТекста(Ответ.Текст());
		
		Если ОтветСервиса.ЕстьОшибка Тогда
			Сообщить(ОтветСервиса.СодержаниеОшибки);
			Возврат Ложь;
		КонецЕсли;
		
	Иначе
		ВызватьИсключение(Ответ.Текст());
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции // ХранилищеСуществует()

// Создает новое хранилище 1С
//
// Параметры:
//   Адрес - Строка - URL-ссылка на сервер хранилищ
//   ИмяХранилища - Строка - имя хранилища. Например: `MyTrade` или `Trade/MyRepo`.
//   ВерсияПлатформы - Строка - версия платформы 1С. Например: 8.3.12.1855
//   ИмяПользователя - Строка - пользователь хранилища
//   ПарольПользователя - Строка - пароль пользователя хранилища
//
//  Возвращаемое значение:
//   Строка - имя хранилища
//
Функция НовоеХранилище1C(Знач Адрес, Знач ИмяХранилища, Знач ВерсияПлатформы, Знач ИмяПользователя, 
	Знач ПарольПользователя) Экспорт
	
	ХешПароляПользователя = Вспомогательный.ХешированныйПароль(ПарольПользователя);
	ШаблонКонфигурации = Вспомогательный.ШаблонКонфигурацииДляХранилища();
	
	ПараметрыТелаЗапроса = Новый Структура;
	ПараметрыТелаЗапроса.Вставить("ИмяХранилища", ИмяХранилища);
	ПараметрыТелаЗапроса.Вставить("ВерсияПлатформы", ВерсияПлатформы);
	ПараметрыТелаЗапроса.Вставить("ИмяПользователя", ИмяПользователя);
	ПараметрыТелаЗапроса.Вставить("ХешПароляПользователя", ХешПароляПользователя);
	ПараметрыТелаЗапроса.Вставить("ШаблонКонфигурации", ШаблонКонфигурации);
	
	ТелоЗапроса = МенеджерЗапросов.ТелоЗапросаНаСозданиеХранилища(ПараметрыТелаЗапроса);
	
	Ответ = КоннекторHTTP.Post(Адрес, ТелоЗапроса);
	Результат = Ответ.Текст();
	
	Если Ответ.КодСостояния = 200 Тогда
		ОтветСервиса = ОбработкаXML.ПрочитатьОтветИзТекста(Результат);
		Если ОтветСервиса.ЕстьОшибка Тогда
			ВызватьИсключение(ОтветСервиса.СодержаниеОшибки);
		КонецЕсли;
	Иначе
		ВызватьИсключение(Результат);
	КонецЕсли;
	
	Возврат ИмяХранилища;
	
КонецФункции

#КонецОбласти