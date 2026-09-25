import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  await prisma.entry.deleteMany();
  await prisma.category.deleteMany();
  await prisma.user.deleteMany();

  const user = await prisma.user.create({
    data: {
      login: 'ola',
      email: 'ola@a.pl',
      password: '123abc',
    },
  });

  const category = await prisma.category.create({
    data: {
      name: 'Rośliny',
      color: '#4CAF50', // Zielony
      hasContent: true,
      hasPhotos: true,
      hasDate: true,
      defaultToCurrentDate: true,
      allowTimeRange: false,
      userId: user.id,
    },
  });

  const entry = await prisma.entry.create({
    data: {
      title: 'First Entry',
      content: 'I hope it works!',
      userId: user.id,
      categoryId: category.id,
    },
  });

  console.log('Seedowanie bazy danych zakończone sukcesem!');
  console.log({ user, category, entry });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });