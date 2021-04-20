FROM perl:5.32.1

RUN cpan install App::cpanminus
COPY cpanfile cpanfile
RUN cpanm --installdeps .

COPY . .

ENTRYPOINT ["./app.pl", "prefork", "-m", "production", "-l", "http://0.0.0.0:8080", "-w", "10", "-c", "1"]