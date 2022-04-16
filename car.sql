-- Create tables

create table if not exists car (
	id_car serial primary key,
	license_plate varchar,
	model varchar,
	color varchar,
	constraint unique_license_plate unique(license_plate)
);

create table if not exists public.people(
	id_person serial,
	name varchar,
	cpf varchar unique,
	type varchar,
	primary key (id_person),
	constraint unique_cpf unique(cpf)
);


create table if not exists public.exit(
	id_exit serial primary key,
	id_car integer,
	id_customer integer,
	id_employee integer,
	date_exit Date,
	is_return boolean,
	foreign key (id_customer) references public.people (id_person),
	foreign key (id_employee) references public.people (id_person),
	foreign key (id_car) references public.car (id_car)
);

ALTER TABLE public."exit" ALTER COLUMN date_exit SET DEFAULT current_date;
ALTER TABLE public."exit" ALTER COLUMN is_return SET DEFAULT false;
ALTER TABLE public."exit" ALTER COLUMN id_car SET NOT NULL;
ALTER TABLE public."exit" ALTER COLUMN id_customer SET NOT NULL;
ALTER TABLE public."exit" ALTER COLUMN id_employee SET NOT NULL;


create table if not exists public.return(
	id_return serial primary key,
	id_exit integer,
	date_return Date,
	foreign key (id_exit) references public.exit (id_exit)
);

ALTER TABLE public."return" ALTER COLUMN id_exit SET NOT NULL;
ALTER TABLE public."return" ALTER COLUMN date_return SET DEFAULT current_date;


-- initial inserts

INSERT INTO public.car
(license_plate, model, color)
VALUES('MYV-5603', 'Brasilia', 'Amarelo');

INSERT INTO public.car
(license_plate, model, color)
VALUES('IVP-9982', 'Camaro', 'Amarelo');

INSERT INTO public.car
(license_plate, model, color)
VALUES('NCC-2074', 'Laika 1.6', 'Vermelho');

INSERT INTO public.people
("name", cpf, "type")
VALUES('John Cena', '10667395016', 'EMPLOYEE');

INSERT INTO public.people
("name", cpf, "type")
VALUES('Luke Skywalker', '04261897016', 'CUSTOMER');

INSERT INTO public.people
("name", cpf, "type")
VALUES('Arthur Pendragon', '29648511071', 'CUSTOMER');

-- trigger para ser chamada quando insere um novo retorno
create trigger tg_change_is_return after
insert
    on
    public.return for each row execute procedure fc_change_is_return();

-- function chamada quando insere um novo retorno
CREATE OR REPLACE FUNCTION public.fc_change_is_return()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE
        public."exit" 
    SET
        is_return  = true
    WHERE
        id_exit  = new.id_exit;
       return null;
END;$function$
;


--  trigger chamada ao inserir novo campo em saída

create trigger tg_create_return after
insert
    on
    public.exit for each row execute procedure create_return();

-- function chamada ao inserir novo campo na tabela de saída

CREATE OR REPLACE FUNCTION public.create_return()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
if new.is_return = true then
  INSERT INTO public."return" (id_exit) VALUES(new.id_exit);
 end if;
     return null;
END;$function$
;
