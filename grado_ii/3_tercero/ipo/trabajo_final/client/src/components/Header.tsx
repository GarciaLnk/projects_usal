import React, { useContext, useState } from "react";
import {
  createStyles,
  Header,
  Container,
  Group,
  Button,
  Burger,
  BackgroundImage,
} from "@mantine/core";
import { useBooleanToggle } from "@mantine/hooks";
import { UltraLogo } from "../shared/UltraLogo";
import { UserContext } from "../App";
import { useNavigate } from "react-router-dom";

const HEADER_HEIGHT = 80;

const useStyles = createStyles((theme) => ({
  inner: {
    height: HEADER_HEIGHT,
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    [theme.fn.largerThan("xl")]: {
      margin: "0 10% 0 10%",
      padding: 0,
    },
  },

  links: {
    [theme.fn.smallerThan("sm")]: {
      display: "none",
    },
    [theme.fn.largerThan("lg")]: {
      gap: "75px",
    },
  },

  burger: {
    [theme.fn.largerThan("sm")]: {
      display: "none",
    },
  },

  link: {
    display: "block",
    lineHeight: 1,
    padding: "8px 12px",
    borderRadius: theme.radius.sm,
    textDecoration: "none",
    color:
      theme.colorScheme === "dark"
        ? theme.colors.dark[0]
        : theme.colors.gray[7],
    fontSize: "24px",
    fontWeight: 700,
    fontFamily: "Space Grotesk, sans-serif",
    letterSpacing: "0.1em",

    "&:hover": {
      backgroundColor:
        theme.colorScheme === "dark"
          ? theme.colors.dark[6]
          : theme.colors.gray[0],
    },
  },

  linkLabel: {
    marginRight: 5,
  },

  linkActive: {
    "&, &:hover": {
      color: "#339AF0",
    },
  },
}));

export function HeaderAction() {
  const { classes, cx } = useStyles();
  const [opened, toggleOpened] = useBooleanToggle(false);
  const userContext: any = useContext(UserContext);
  const navigate = useNavigate();

  var links;
  if (!userContext.name) {
    links = [
      { link: "/", label: "Inicio" },
      { link: "/explore", label: "Explora" },
      { link: "/support", label: "Soporte" },
      { link: "/login", label: "Iniciar sesión" },
    ];
  } else {
    links = [
      { link: "/", label: "Inicio" },
      { link: "/explore", label: "Explora" },
      { link: "/support", label: "Soporte" },
      { link: "/#", label: "Cerrar sesión" },
    ];
  }

  const [active, setActive] = useState(links[0].link);

  const items = links.map((link) => {
    return (
      <a
        key={link.label}
        href={link.link}
        className={cx(classes.link, {
          [classes.linkActive]: active === link.link,
        })}
        onClick={(event) => {
          event.preventDefault();
          setActive(link.link);
          if (link.link === "/#") {
            try {
              fetch("/api/logout", { method: "DELETE" });
            } catch (error) {
              console.error("There was an error fetch auth", error);
              return;
            }
            navigate(0);
          } else navigate(link.link);
        }}
      >
        {link.label}
      </a>
    );
  });

  return (
    <Header height={HEADER_HEIGHT} sx={{ borderBottom: 0 }} mb={0}>
      <BackgroundImage
        src="bg.png"
        style={{
          background: "url(bg.png) no-repeat center center fixed",
          backgroundSize: "cover",
        }}
      >
        {" "}
        <Container className={classes.inner} fluid>
          <Group>
            <Burger
              opened={opened}
              onClick={() => toggleOpened()}
              className={classes.burger}
              size="sm"
            />
            <UltraLogo />
          </Group>
          <Group spacing={5} className={classes.links}>
            {items}
          </Group>
          <Button<"a">
            component="a"
            href="/ultra.zip"
            radius="xl"
            sx={{ height: 30 }}
          >
            Descargar código
          </Button>
        </Container>
      </BackgroundImage>
    </Header>
  );
}
