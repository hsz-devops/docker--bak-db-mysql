FROM ez123/db-mysql:5.7-ssl

MAINTAINER HighSkillz <webdev@highskillz.com>

COPY ./src/entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
# CMD ["mysqldump"]
