FROM ez123/db-mysql:5.7

MAINTAINER HighSkillz <webdev@highskillz.com>

COPY ./src/entrypoint /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["mysqldump"]
