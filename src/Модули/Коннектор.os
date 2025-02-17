#Использовать 1connector

Функция Post(Адрес, ТелоЗапроса) Экспорт
	
	Если ЭтоТСРАдрес(Адрес) Тогда
		Возврат ВыполнитьЗапросТСР(Адрес, ТелоЗапроса);
	Иначе
		Возврат КоннекторHTTP.Post(Адрес, ТелоЗапроса);
	КонецЕсли;
	
КонецФункции

Функция ВыполнитьЗапросТСР(Знач Адрес, Знач ТелоЗапроса)
	
	СтруктураАдреса = РазобратьСтруктуруАдреса(Адрес);
	ДвоичныеДанныеТелоЗапроса = СформироватьДвоичныеДанныеТелоЗапроса(ТелоЗапроса);
	
	СоединениеТСР = Новый TCPСоединение(СтруктураАдреса.Сервер, СтруктураАдреса.Порт);
	СоединениеТСР.ПрочитатьДвоичныеДанные();

	СоединениеТСР.ОтправитьДвоичныеДанные(ДвоичныеДанныеТелоЗапроса);
	
	ДвоичныеДанныеОтвет = СоединениеТСР.ПрочитатьДвоичныеДанные();
	СоединениеТСР.Закрыть();
	
	Ответ = РазобратьОтвет(ДвоичныеДанныеОтвет);
	
	Возврат Ответ;
	
КонецФункции

Функция РазобратьСтруктуруАдреса(Знач Адрес)
	
	СтруктураАдреса = Новый Структура("Сервер,Порт,ИмяХранилища", "", "", "");
	
	Адрес = СтрЗаменить(Адрес, "tcp://", "");
	Адрес = СтрЗаменить(Адрес, "https://", "");
	Адрес = СтрЗаменить(Адрес, "http://", "");
	Массив = СтрРазделить(Адрес, "/");
	
	Если Массив.Количество() > 0 Тогда
		СерверПорт = Массив[0];
		Массив.Удалить(0);
		
		СтруктураАдреса.ИмяХранилища = СтрСоединить(Массив, "/");
		
		Массив = СтрРазделить(СерверПорт, ":");
		СтруктураАдреса.Сервер = Массив[0];
		Если Массив.Количество() > 1 Тогда
			СтруктураАдреса.Порт = Массив[1];
			Если ПустаяСтрока(СтруктураАдреса.Порт) Тогда
				СтруктураАдреса.Порт = "1542";
			КонецЕсли;
		Иначе
			СтруктураАдреса.Порт = "1542";
		КонецЕсли;
	КонецЕсли;
	
	Возврат СтруктураАдреса;
	
КонецФункции

Функция СформироватьДвоичныеДанныеТелоЗапроса(Знач ТелоЗапроса)
	
	Если ТипЗнч(ТелоЗапроса) = Тип("ДвоичныеДанные") Тогда
		ДвоичныеДанныеТелоЗапроса = ТелоЗапроса;
	Иначе
		ТелоЗапроса = СтрЗаменить(ТелоЗапроса, Символы.ПС, "");
		ДвоичныеДанныеТелоЗапроса = ПереопределениеOneScript.ПолучитьДвоичныеДанныеИзСтроки(ТелоЗапроса, КодировкаТекста.UTF8, Истина);
	КонецЕсли;
	
	МассивДвДанных = Новый Массив;
	МассивДвДанных.Добавить(СформироватьЗаголовокСообщения(ДвоичныеДанныеТелоЗапроса.Размер()));
	МассивДвДанных.Добавить(ДвоичныеДанныеТелоЗапроса);
	МассивДвДанных.Добавить(ПолучитьДвоичныеДанныеИзHexСтроки("66 53 b2 a6"));
	
	Возврат СоединитьДвоичныеДанные(МассивДвДанных);
	
КонецФункции

Функция СформироватьЗаголовокСообщения(РазмерТелаЗапроса)
	
	ТекстЗаголовка = "POST  HTTP/1.1" + Символы.ВК + Символы.ПС
		+ "Content-Length: " + РазмерТелаЗапроса + Символы.ВК + Символы.ПС
		+ "Content-Type: application/xml" + Символы.ВК + Символы.ПС
		+ "Accept: application/xml" + Символы.ВК + Символы.ПС
		+ Символы.ВК + Символы.ПС;

	Возврат ПолучитьДвоичныеДанныеИзСтроки(ТекстЗаголовка, "ISO-8859-1");
	
КонецФункции

Функция РазобратьОтвет(ДвДанные)

	Ответ = Новый ОтветНТТР(ДвДанные);

	Возврат Ответ;
	
КонецФункции

Функция ЭтоТСРАдрес(Знач Адрес) Экспорт
	
	Возврат СтрНачинаетсяС(Адрес, "tcp://");
	
КонецФункции