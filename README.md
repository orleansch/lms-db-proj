Проект реляционной базы данных для онлайн-платформы курсов (Learning Management System).

База данных реализована на PostgreSQL 18 и разворачивается автоматически через Docker Compose.

---

## Описание проекта

Система предназначена для хранения информации о:

- пользователях (студенты, преподаватели, администраторы)
- курсах и категориях
- модулях и уроках
- заданиях и отправках работ
- оплатах
- сертификатах
- регистрациях на курсы (enrollments)

---
Логически связанная предметная область  
Структура в 3 нормальной форме (3НФ)  
Constraints (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK)  
DEFAULT значения  
Индексы  
Триггеры (обычные и event trigger)  
Автоматическое развертывание через Docker Compose  
Скрипт автозаполнения случайными данными  
Тест производительности (EXPLAIN ANALYZE)  
Примеры аналитических запросов  

---

## Для запуска проекта:

- Docker Desktop
- Git

---

## Запуск
git clone https://github.com/orleansch/lms-db-proj
cd lms-database
docker compose up -d(запуск контейнера)

PostgreSQL автоматически:

- создаст базу данных
- выполнит init.sql
- заполнит данные из perf_data.sql

---

## Коннект

Host: `localhost`  
Port: `5433`  
Database: `lms` 
User: `postgres`  
Password: `postgres`
(проверено на dbeaver, pgadmin 4)
---

## Тест производительности

Выполнить:
docker exec -it lms_db psql -U postgres -d test_bd -f performance_test.sql
Используется: EXPLAIN ANALYZE

Для сравнения:

- Index Scan
- Seq Scan
- Planning Time
- Execution Time

---

## Примеры аналитических запросов

Содержатся в файле: queries.sql

---

## Триггеры

Реализованы:

1. Автоматическая выдача сертификата при завершении курса
2. Проверка, что оценка меньше или равна макс. значению

---

## Стек

- PostgreSQL 18
- Docker Compose

---












