import React from "react";
import {
  Container,
  SimpleGrid,
  useMantineTheme,
  createStyles,
  Image,
  Text,
} from "@mantine/core";

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

interface AllTripsGridProps {
  data?: FeatureProps[];
}

export function AllTripsGrid({
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
    }, {
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
    }, {
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
}: AllTripsGridProps) {
  const { classes } = useStyles();
  const theme = useMantineTheme();
  const features = data.map((feature, index) => (
    <Feature {...feature} key={index} />
  ));

  return (
    <Container className={classes.wrapper}>
      <Text
        style={{
          fontFamily: "Space Grotesk, sans-serif",
          fontWeight: 700,
          fontSize: "24px",
          letterSpacing: "0.1em",
          paddingTop: "24px",
        }}
      >
        Todos los viajes
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
