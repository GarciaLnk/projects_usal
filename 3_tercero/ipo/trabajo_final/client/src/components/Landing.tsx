import React, { useContext } from "react";
import {
  Title,
  Container,
  SimpleGrid,
  useMantineTheme,
  createStyles,
  Image,
  Text,
  TextInput,
  TextInputProps,
  ActionIcon,
} from "@mantine/core";
import { Search, ArrowRight, ArrowLeft } from "tabler-icons-react";
import { UserContext } from "../App";

export function InputWithButton(props: TextInputProps) {
  const theme = useMantineTheme();

  return (
    <TextInput
      icon={<Search size={18} />}
      radius="xl"
      size="md"
      rightSection={
        <ActionIcon
          size={32}
          radius="xl"
          color={theme.primaryColor}
          variant="filled"
        >
          {theme.dir === "ltr" ? (
            <ArrowRight size={18} />
          ) : (
            <ArrowLeft size={18} />
          )}
        </ActionIcon>
      }
      placeholder="Busca planetas, galaxias u otros destinos"
      rightSectionWidth={42}
      {...props}
    />
  );
}

interface FeatureProps {
  path: string;
}

export function Feature({ path }: FeatureProps) {
  return (
    <div>
      <Image src={path} />
    </div>
  );
}

const useStyles = createStyles((theme) => ({
  wrapper: {
    padding: 0,
    paddingBottom: "32px",
    margin: "0 10% 0 10%",
    maxWidth: "100%",
  },

  title: {
    fontFamily: `Space Grotesk, ${theme.fontFamily}`,
    fontWeight: 900,
    textAlign: "center",
    paddingTop: "10px",

    [theme.fn.smallerThan("sm")]: {
      fontSize: 28,
      textAlign: "left",
    },
  },

  description: {
    textAlign: "center",

    [theme.fn.smallerThan("sm")]: {
      textAlign: "left",
    },
  },
}));

interface PlanetsGridProps {
  data?: FeatureProps[];
}

export function PlanetsGrid({
  data = [
    {
      path: "planeta2.png",
    },
    {
      path: "planeta1.png",
    },
    {
      path: "planeta3.png",
    },
  ],
}: PlanetsGridProps) {
  const { classes } = useStyles();
  const theme = useMantineTheme();
  const features = data.map((feature, index) => (
    <Feature {...feature} key={index} />
  ));

  return (
    <Container className={classes.wrapper}>
      <SimpleGrid
        mt={10}
        cols={3}
        spacing={theme.spacing.xl * 2}
        breakpoints={[
          { maxWidth: 980, cols: 2, spacing: "xl" },
          { maxWidth: 755, cols: 1, spacing: "xl" },
        ]}
      >
        {features}
      </SimpleGrid>
    </Container>
  );
}

interface TripsGridProps {
  data?: FeatureProps[];
}

export function TripsGrid({
  data = [
    {
      path: "tarjeta5.jpg",
    },
    {
      path: "tarjeta4.jpg",
    },
    {
      path: "tarjeta3.jpg",
    },
    {
      path: "tarjeta2.jpg",
    },
    {
      path: "tarjeta1.jpg",
    },
    {
      path: "tarjeta5.jpg",
    },
    {
      path: "tarjeta4.jpg",
    },
    {
      path: "tarjeta3.jpg",
    },
    {
      path: "tarjeta2.jpg",
    },
    {
      path: "tarjeta1.jpg",
    },
    {
      path: "tarjeta5.jpg",
    },
    {
      path: "tarjeta4.jpg",
    },
    {
      path: "tarjeta3.jpg",
    },
    {
      path: "tarjeta2.jpg",
    },
    {
      path: "tarjeta1.jpg",
    },
  ],
}: TripsGridProps) {
  const { classes } = useStyles();
  const theme = useMantineTheme();
  const features = data.map((feature, index) => (
    <Feature {...feature} key={index} />
  ));

  const userContext: any = useContext(UserContext);

  return (
    <Container className={classes.wrapper}>
      <InputWithButton
        style={{
          paddingBottom: "12px",
          width: "50%",
          margin: "auto",
          paddingTop: "24px",
        }}
      />
      {userContext.name && (
        <Title className={classes.title}>
          Hola {userContext.name}, ¿a dónde quieres viajar?
        </Title>
      )}
      <PlanetsGrid />

      <Text
        style={{
          fontFamily: "Space Grotesk, sans-serif",
          fontWeight: 700,
          fontSize: "24px",
          letterSpacing: "0.1em",
        }}
      >
        Viajes
      </Text>

      <SimpleGrid
        mt={10}
        cols={4}
        spacing={theme.spacing.lg}
        breakpoints={[
          { maxWidth: 980, cols: 3, spacing: "md" },
          { maxWidth: 755, cols: 2, spacing: "sm" },
          { maxWidth: 600, cols: 1, spacing: "sm" },
        ]}
      >
        {features}
      </SimpleGrid>
    </Container>
  );
}
