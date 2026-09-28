#Использовать ".."
#Использовать asserts

// BSLLS:MagicNumber-off
// BSLLS:DuplicateStringLiteral-off

// -----------------------------------------------------------------------------
// Тесты форматов выдачи: выбор формата по заголовку Accept (Prometheus Content
// Negotiation), OpenMetrics 1.0.0 (# UNIT, _created, exemplars, # EOF, типы info,
// stateset и unknown) и схемы экранирования имен (underscores, dots, values,
// allow-utf-8).
// -----------------------------------------------------------------------------

// Без заголовка Accept формат - text 0.0.4 с экранированием underscores, выдача
// совпадает с Сериализовать без формата.
&Тест
Процедура ТестДолжен_ФорматПоУмолчаниюТекст004() Экспорт
	Формат = PrometheusTextFormat.ВыбратьФормат("");
	Семейства = Новый Массив;
	Семейства.Добавить(СемействоСчетчикаЗаданий());

	Утверждения.ПроверитьРавенство(
		"text/plain; version=0.0.4; charset=utf-8", Формат.ТипКонтента,
		"Content-Type формата по умолчанию");
	Утверждения.ПроверитьРавенство(
		PrometheusTextFormat.Сериализовать(Семейства), PrometheusTextFormat.Сериализовать(Семейства, Формат),
		"Выдача в формате по умолчанию");
	Утверждения.ПроверитьРавенство(
		PrometheusTextFormat.ContentType(), PrometheusTextFormat.ContentType(Формат),
		"Content-Type без формата и в формате по умолчанию");
КонецПроцедуры

// Формат с наибольшим весом q из поддерживаемых: text 0.0.4 и 1.0.0, OpenMetrics 0.0.1
// и 1.0.0. Параметр escaping задает схему экранирования, allow-utf-8 - только в версии 1.0.0.
&Тест
Процедура ТестДолжен_СогласованиеФорматаПоЗаголовкуAccept() Экспорт
	Случаи = Новый Массив;
	ДобавитьСлучайСогласования(Случаи, "*/*", "text/plain; version=0.0.4; charset=utf-8");
	ДобавитьСлучайСогласования(Случаи, "text/plain;version=0.0.4", "text/plain; version=0.0.4; charset=utf-8");
	ДобавитьСлучайСогласования(Случаи,
		"text/plain;version=0.0.4;escaping=allow-utf-8",
		"text/plain; version=0.0.4; charset=utf-8");
	ДобавитьСлучайСогласования(Случаи,
		"text/plain;version=0.0.4;escaping=dots",
		"text/plain; version=0.0.4; charset=utf-8; escaping=dots");
	ДобавитьСлучайСогласования(Случаи,
		"text/plain;version=1.0.0;escaping=allow-utf-8",
		"text/plain; version=1.0.0; charset=utf-8; escaping=allow-utf-8");
	ДобавитьСлучайСогласования(Случаи,
		"text/plain;version=1.0.0",
		"text/plain; version=1.0.0; charset=utf-8; escaping=underscores");
	ДобавитьСлучайСогласования(Случаи,
		"application/openmetrics-text;version=0.0.1;q=0.5,text/plain;version=0.0.4;q=0.3",
		"application/openmetrics-text; version=0.0.1; charset=utf-8");
	ДобавитьСлучайСогласования(Случаи,
		"application/openmetrics-text;version=1.0.0;escaping=allow-utf-8;q=0.6,"
			+ "application/openmetrics-text;version=0.0.1;q=0.5,"
			+ "text/plain;version=1.0.0;escaping=allow-utf-8;q=0.4,text/plain;version=0.0.4;q=0.3,*/*;q=0.2",
		"application/openmetrics-text; version=1.0.0; charset=utf-8; escaping=allow-utf-8");
	ДобавитьСлучайСогласования(Случаи,
		"text/plain;version=0.0.4;q=0.9,application/openmetrics-text;version=1.0.0;q=0.5",
		"text/plain; version=0.0.4; charset=utf-8");
	ДобавитьСлучайСогласования(Случаи,
		"application/openmetrics-text;version=1.0.0;q=0,text/plain",
		"text/plain; version=0.0.4; charset=utf-8");
	ДобавитьСлучайСогласования(Случаи,
		"application/vnd.google.protobuf;proto=io.prometheus.client.MetricFamily;encoding=delimited",
		"text/plain; version=0.0.4; charset=utf-8");
	ДобавитьСлучайСогласования(Случаи,
		"text/plain;version=2.0.0,application/openmetrics-text",
		"application/openmetrics-text; version=0.0.1; charset=utf-8");

	Для Каждого Случай Из Случаи Цикл
		Формат = PrometheusTextFormat.ВыбратьФормат(Случай.Accept);
		Утверждения.ПроверитьРавенство(Случай.ТипКонтента, Формат.ТипКонтента, "Accept: " + Случай.Accept);
	КонецЦикла;
КонецПроцедуры

// В OpenMetrics у семейства счетчика нет суффикса _total, у сэмпла он есть всегда; время
// создания серии (Создано) выводится сэмплом _created; в HELP экранируются кавычки.
&Тест
Процедура ТестДолжен_OpenMetricsСчетчикСВременемСоздания() Экспорт
	Семейства = Новый Массив;
	Семейства.Добавить(СемействоСчетчикаЗаданий());
	Сэмплы = Новый Массив;
	Сэмплы.Добавить(Сэмпл("requests", 3));
	Семейства.Добавить(Семейство("requests", "counter", "", Сэмплы));

	Текст = PrometheusTextFormat.Сериализовать(Семейства, ФорматOpenMetrics());

	Утверждения.ПроверитьРавенство(
		"# HELP jobs Задания \""срочные\""" + Символы.ПС
			+ "# TYPE jobs counter" + Символы.ПС
			+ "jobs_total{queue=""fast""} 5" + Символы.ПС
			+ "jobs_created{queue=""fast""} 1700000000.5" + Символы.ПС
			+ "# TYPE requests counter" + Символы.ПС
			+ "requests_total 3" + Символы.ПС
			+ "# EOF" + Символы.ПС,
		Текст,
		"Выдача OpenMetrics");
КонецПроцедуры

// Text format 0.0.4 не поддерживает _created, # UNIT и exemplars: поля Создано, Единица и
// Экземпляр не меняют выдачу.
&Тест
Процедура ТестДолжен_ТекстБезВремениСозданияЕдиницыИЭкземпляров() Экспорт
	Семейства = Новый Массив;
	Семейства.Добавить(СемействоСчетчикаЗаданий());
	Семейства.Добавить(СемействоГистограммыСЭкземпляром());

	Текст = PrometheusTextFormat.Сериализовать(Семейства);

	Утверждения.ПроверитьРавенство(
		"# TYPE http_duration_seconds histogram" + Символы.ПС
			+ "http_duration_seconds_bucket{le=""0.5"",route=""/a""} 1" + Символы.ПС
			+ "http_duration_seconds_bucket{le=""+Inf"",route=""/a""} 1" + Символы.ПС
			+ "http_duration_seconds_sum{route=""/a""} 0.3" + Символы.ПС
			+ "http_duration_seconds_count{route=""/a""} 1" + Символы.ПС
			+ "# HELP jobs_total Задания ""срочные""" + Символы.ПС
			+ "# TYPE jobs_total counter" + Символы.ПС
			+ "jobs_total{queue=""fast""} 5" + Символы.ПС,
		Текст,
		"Выдача text 0.0.4");
КонецПроцедуры

// В OpenMetrics # UNIT выводится, если имя семейства оканчивается на единицу; exemplar
// выводится у бакета гистограммы, _created - после _count серии.
&Тест
Процедура ТестДолжен_OpenMetricsГистограммаСЕдиницейИЭкземпляром() Экспорт
	Семейства = Новый Массив;
	Семейства.Добавить(СемействоГистограммыСЭкземпляром());
	Сэмплы = Новый Массив;
	Сэмплы.Добавить(Сэмпл("jobs_total", 1));
	Семейства.Добавить(Семейство("jobs_total", "counter", "", Сэмплы, "seconds"));

	Текст = PrometheusTextFormat.Сериализовать(Семейства, ФорматOpenMetrics());

	Утверждения.ПроверитьРавенство(
		"# TYPE http_duration_seconds histogram" + Символы.ПС
			+ "# UNIT http_duration_seconds seconds" + Символы.ПС
			+ "http_duration_seconds_bucket{le=""0.5"",route=""/a""} 1"
			+ " # {span_id=""b7ad6b7169203331"",trace_id=""0af7651916cd43dd8448eb211c80319c""} 0.3 1700000003"
			+ Символы.ПС
			+ "http_duration_seconds_bucket{le=""+Inf"",route=""/a""} 1" + Символы.ПС
			+ "http_duration_seconds_sum{route=""/a""} 0.3" + Символы.ПС
			+ "http_duration_seconds_count{route=""/a""} 1" + Символы.ПС
			+ "http_duration_seconds_created{route=""/a""} 1700000000" + Символы.ПС
			+ "# TYPE jobs counter" + Символы.ПС
			+ "jobs_total 1" + Символы.ПС
			+ "# EOF" + Символы.ПС,
		Текст,
		"Выдача OpenMetrics: # UNIT только у семейства с суффиксом единицы");
КонецПроцедуры

// Типы info, stateset и unknown есть только в OpenMetrics. В text format info выводится
// gauge с суффиксом _info, stateset - gauge, unknown - untyped; untyped в OpenMetrics - unknown.
&Тест
Процедура ТестДолжен_ТипыInfoStatesetUnknown() Экспорт
	Семейства = Новый Массив;
	Семейства.Добавить(Семейство("build", "info", "", МассивИзСэмпла(Сэмпл("build_info", 1, "version", "1.2"))));
	Семейства.Добавить(Семейство("state", "stateset", "", МассивИзСэмпла(Сэмпл("state", 1, "state", "ok"))));
	Семейства.Добавить(Семейство("mystery", "unknown", "", МассивИзСэмпла(Сэмпл("mystery", 2))));
	Семейства.Добавить(Семейство("legacy", "untyped", "", МассивИзСэмпла(Сэмпл("legacy", 3))));

	Текст = PrometheusTextFormat.Сериализовать(Семейства);
	ОткрытыеМетрики = PrometheusTextFormat.Сериализовать(Семейства, ФорматOpenMetrics());

	Утверждения.ПроверитьРавенство(
		"# TYPE build_info gauge" + Символы.ПС
			+ "build_info{version=""1.2""} 1" + Символы.ПС
			+ "# TYPE legacy untyped" + Символы.ПС
			+ "legacy 3" + Символы.ПС
			+ "# TYPE mystery untyped" + Символы.ПС
			+ "mystery 2" + Символы.ПС
			+ "# TYPE state gauge" + Символы.ПС
			+ "state{state=""ok""} 1" + Символы.ПС,
		Текст,
		"Типы в text format");
	Утверждения.ПроверитьРавенство(
		"# TYPE build info" + Символы.ПС
			+ "build_info{version=""1.2""} 1" + Символы.ПС
			+ "# TYPE legacy unknown" + Символы.ПС
			+ "legacy 3" + Символы.ПС
			+ "# TYPE mystery unknown" + Символы.ПС
			+ "mystery 2" + Символы.ПС
			+ "# TYPE state stateset" + Символы.ПС
			+ "state{state=""ok""} 1" + Символы.ПС
			+ "# EOF" + Символы.ПС,
		ОткрытыеМетрики,
		"Типы в OpenMetrics");
КонецПроцедуры

&Тест
Процедура ТестДолжен_ПустаяВыдачаOpenMetrics() Экспорт
	Текст = PrometheusTextFormat.Сериализовать(Новый Массив, ФорматOpenMetrics());

	Утверждения.ПроверитьРавенство("# EOF" + Символы.ПС, Текст, "Пустая выдача OpenMetrics");
КонецПроцедуры

// Схема underscores (по умолчанию) заменяет недопустимые символы имен на "_", dots - "_" на
// "__" и "." на "_dot_", values - добавляет префикс U__ и код символа.
&Тест
Процедура ТестДолжен_ЭкранированиеИменПоСхеме() Экспорт
	Семейства = Новый Массив;
	Семейства.Добавить(Семейство("foo.bar", "gauge", "", МассивИзСэмпла(Сэмпл("foo.bar", 1, "a:b", "x"))));

	ПоУмолчанию = PrometheusTextFormat.Сериализовать(Семейства);
	Точки = PrometheusTextFormat.Сериализовать(
		Семейства, PrometheusTextFormat.ВыбратьФормат("text/plain;version=0.0.4;escaping=dots"));
	Значения = PrometheusTextFormat.Сериализовать(
		Семейства, PrometheusTextFormat.ВыбратьФормат("text/plain;version=1.0.0;escaping=values"));

	Утверждения.ПроверитьРавенство(
		"# TYPE foo_bar gauge" + Символы.ПС + "foo_bar{a_b=""x""} 1" + Символы.ПС, ПоУмолчанию,
		"Схема underscores");
	Утверждения.ПроверитьРавенство(
		"# TYPE foo_dot_bar gauge" + Символы.ПС + "foo_dot_bar{a__b=""x""} 1" + Символы.ПС, Точки,
		"Схема dots");
	Утверждения.ПроверитьРавенство(
		"# TYPE U__foo_2e_bar gauge" + Символы.ПС + "U__foo_2e_bar{U__a_3a_b=""x""} 1" + Символы.ПС, Значения,
		"Схема values");
КонецПроцедуры

// Схема allow-utf-8: имена, недопустимые в классическом формате, выводятся в кавычках.
&Тест
Процедура ТестДолжен_ИменаUtf8ВКавычках() Экспорт
	Сэмплы = Новый Массив;
	Сэмплы.Добавить(Сэмпл("foo.bar_total", 1, "a.b", "v"));
	Сэмплы.Добавить(Сэмпл("foo.bar_total", 2, "ok", "w"));
	Семейства = Новый Массив;
	Семейства.Добавить(Семейство("foo.bar_total", "counter", "Счетчик", Сэмплы));
	Формат = PrometheusTextFormat.ВыбратьФормат("text/plain;version=1.0.0;escaping=allow-utf-8");

	Текст = PrometheusTextFormat.Сериализовать(Семейства, Формат);

	Утверждения.ПроверитьРавенство(
		"# HELP ""foo.bar_total"" Счетчик" + Символы.ПС
			+ "# TYPE ""foo.bar_total"" counter" + Символы.ПС
			+ "{""foo.bar_total"",""a.b""=""v""} 1" + Символы.ПС
			+ "{""foo.bar_total"",ok=""w""} 2" + Символы.ПС,
		Текст,
		"Имена UTF-8 в кавычках");
КонецПроцедуры

// Фасад: формат выбирается по Accept, выдача и Content-Type - в выбранном формате.
&Тест
Процедура ТестДолжен_ФасадВыдаетМетрикиВСогласованномФормате() Экспорт
	Семейства = Новый Массив;
	Семейства.Добавить(СемействоСчетчикаЗаданий());

	Формат = Prometheus.ВыбратьФормат("application/openmetrics-text;version=1.0.0");
	Текст = Prometheus.СериализоватьВТекст(Семейства, Формат);

	Утверждения.ПроверитьРавенство(
		"application/openmetrics-text; version=1.0.0; charset=utf-8; escaping=underscores",
		Prometheus.ContentTypeМетрик(Формат),
		"Content-Type OpenMetrics");
	Утверждения.ПроверитьИстину(СтрЗаканчиваетсяНа(Текст, "# EOF" + Символы.ПС), "Выдача OpenMetrics с # EOF");
	Утверждения.ПроверитьРавенство(
		"text/plain; version=0.0.4; charset=utf-8", Prometheus.ContentTypeМетрик(),
		"Content-Type без формата");
КонецПроцедуры

Функция СемействоСчетчикаЗаданий()
	Сэмпл = Сэмпл("jobs_total", 5, "queue", "fast");
	Сэмпл.Вставить("Создано", 1700000000.5);

	Возврат Семейство("jobs_total", "counter", "Задания ""срочные""", МассивИзСэмпла(Сэмпл));
КонецФункции

Функция СемействоГистограммыСЭкземпляром()
	ЛейблыЭкземпляра = Новый Соответствие;
	ЛейблыЭкземпляра.Вставить("trace_id", "0af7651916cd43dd8448eb211c80319c");
	ЛейблыЭкземпляра.Вставить("span_id", "b7ad6b7169203331");
	Бакет = СэмплБакета("http_duration_seconds_bucket", 0.5, 1);
	Бакет.Вставить("Экземпляр", Новый Структура("Лейблы, Значение, Время", ЛейблыЭкземпляра, 0.3, 1700000003));
	Количество = Сэмпл("http_duration_seconds_count", 1, "route", "/a");
	Количество.Вставить("Создано", 1700000000);
	Сэмплы = Новый Массив;
	Сэмплы.Добавить(СэмплБакета("http_duration_seconds_bucket", "+Inf", 1));
	Сэмплы.Добавить(Количество);
	Сэмплы.Добавить(Сэмпл("http_duration_seconds_sum", 0.3, "route", "/a"));
	Сэмплы.Добавить(Бакет);

	Возврат Семейство("http_duration_seconds", "histogram", "", Сэмплы, "seconds");
КонецФункции

Функция Семейство(Имя, Тип, Справка, Сэмплы, Единица = "")
	Семейство = Новый Структура("Имя, Тип, Справка", Имя, Тип, Справка);
	Семейство.Вставить("Сэмплы", Сэмплы);
	Если Единица <> "" Тогда
		Семейство.Вставить("Единица", Единица);
	КонецЕсли;

	Возврат Семейство;
КонецФункции

Функция Сэмпл(ИмяСэмпла, Значение, ИмяЛейбла = "", ЗначениеЛейбла = "")
	Лейблы = Новый Соответствие;
	Если ИмяЛейбла <> "" Тогда
		Лейблы.Вставить(ИмяЛейбла, ЗначениеЛейбла);
	КонецЕсли;

	Возврат Новый Структура("ИмяСэмпла, Лейблы, Значение", ИмяСэмпла, Лейблы, Значение);
КонецФункции

Функция СэмплБакета(ИмяСэмпла, Граница, Значение)
	Сэмпл = Сэмпл(ИмяСэмпла, Значение, "route", "/a");
	Сэмпл.Лейблы.Вставить("le", Граница);

	Возврат Сэмпл;
КонецФункции

Функция МассивИзСэмпла(Сэмпл)
	Сэмплы = Новый Массив;
	Сэмплы.Добавить(Сэмпл);

	Возврат Сэмплы;
КонецФункции

Процедура ДобавитьСлучайСогласования(Случаи, Accept, ТипКонтента)
	Случаи.Добавить(Новый Структура("Accept, ТипКонтента", Accept, ТипКонтента));
КонецПроцедуры

Функция ФорматOpenMetrics()
	Возврат PrometheusTextFormat.ВыбратьФормат("application/openmetrics-text;version=1.0.0");
КонецФункции
